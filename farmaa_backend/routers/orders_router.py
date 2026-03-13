"""Orders router – create, list, update status with validation."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime, timedelta, timezone
from typing import List

from database import get_db
from models import Order, Crop, User
from schemas import OrderCreate, OrderStatusUpdate, OrderOut
from auth import get_current_user_id
from middleware import sanitize_string

router = APIRouter(prefix="/orders", tags=["Orders"])

# Valid status transitions
VALID_STATUS_TRANSITIONS = {
    "pending": {"confirmed", "cancelled"},
    "confirmed": {"processing", "cancelled"},
    "processing": {"shipped", "cancelled"},
    "shipped": {"delivered"},
    "delivered": set(),  # Terminal state
    "cancelled": set(),  # Terminal state
}


def _map_order(order: Order) -> OrderOut:
    """Helper to map Order model to OrderOut schema with all related info."""
    o = OrderOut.model_validate(order)

    # Map Crop info
    if order.crop:
        o.crop_name = order.crop.name
        o.crop_category = order.crop.category
        o.crop_image = order.crop.image_url
        o.price_per_kg = order.crop.price_per_kg

    # Map Buyer info
    if order.buyer:
        o.buyer_name = order.buyer.name
        o.buyer_phone = order.buyer.phone

    # Map Farmer info
    if order.farmer_:
        o.farmer_name = order.farmer_.name
        o.farmer_phone = order.farmer_.phone

    # Payment status logic
    o.payment_status = "paid" if order.payment_id else "pending"

    return o


@router.post("", response_model=OrderOut, status_code=201)
@router.post("/", response_model=OrderOut, status_code=201, include_in_schema=False)
def create_order(body: OrderCreate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == body.crop_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found")
    if not crop.is_available:
        raise HTTPException(status_code=400, detail="Crop is not available")

    # Prevent buyers from ordering their own crops
    if crop.farmer_id == user_id:
        raise HTTPException(status_code=400, detail="You cannot order your own crops")

    # Validate quantity
    if body.quantity_kg <= 0:
        raise HTTPException(status_code=400, detail="Quantity must be positive")
    if body.quantity_kg > crop.stock_kg:
        raise HTTPException(status_code=400, detail=f"Insufficient stock. Available: {crop.stock_kg} kg")
    if crop.min_order_kg and body.quantity_kg < crop.min_order_kg:
        raise HTTPException(
            status_code=400,
            detail=f"Minimum order is {crop.min_order_kg} kg"
        )

    total = round(body.quantity_kg * crop.price_per_kg, 2)

    # Sanitize delivery address
    delivery_address = sanitize_string(body.delivery_address, max_length=500) if body.delivery_address else None

    order = Order(
        buyer_id=user_id,
        farmer_id=crop.farmer_id,
        crop_id=crop.id,
        quantity_kg=body.quantity_kg,
        total_amount=total,
        delivery_address=delivery_address,
        payment_id=body.payment_id,
        razorpay_order_id=body.razorpay_order_id,
        razorpay_signature=body.razorpay_signature,
    )
    db.add(order)

    crop.stock_kg -= body.quantity_kg
    if crop.stock_kg <= 0:
        crop.is_available = False
        crop.status = "sold_out"

    db.commit()
    db.refresh(order)

    return _map_order(order)


@router.get("/my-orders", response_model=List[OrderOut])
def my_orders(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    orders = db.query(Order).filter(
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id)
    ).order_by(Order.created_at.desc()).all()

    return [_map_order(o) for o in orders]


@router.get("/{order_id}", response_model=OrderOut)
def get_order(order_id: str, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    order = db.query(Order).filter(
        Order.id == order_id,
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id),
    ).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    return _map_order(order)


@router.patch("/{order_id}/status", response_model=OrderOut)
def update_order_status(order_id: str, body: OrderStatusUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    valid_statuses = {"pending", "confirmed", "processing", "shipped", "delivered", "cancelled"}
    if body.status not in valid_statuses:
        raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of: {valid_statuses}")

    order = db.query(Order).filter(
        Order.id == order_id,
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id),
    ).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    # Validate status transition
    current_status = order.status
    allowed_next = VALID_STATUS_TRANSITIONS.get(current_status, set())
    if body.status not in allowed_next:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot transition from '{current_status}' to '{body.status}'. "
                   f"Allowed: {allowed_next if allowed_next else 'none (terminal state)'}"
        )

    # Role-based status update permissions
    if body.status == "cancelled":
        # Both buyer and farmer can cancel
        pass
    elif body.status in {"confirmed", "processing", "shipped"}:
        # Only farmer can confirm/process/ship
        if order.farmer_id != user_id:
            raise HTTPException(status_code=403, detail="Only the farmer can update this status")
    elif body.status == "delivered":
        # Only buyer can confirm delivery
        if order.buyer_id != user_id:
            raise HTTPException(status_code=403, detail="Only the buyer can confirm delivery")

    order.status = body.status
    order.updated_at = datetime.now(timezone.utc)

    if body.status == "cancelled":
        crop = db.query(Crop).filter(Crop.id == order.crop_id).first()
        if crop:
            crop.stock_kg += order.quantity_kg
            crop.is_available = True
            if crop.status == "sold_out":
                crop.status = "approved"

    db.commit()
    db.refresh(order)
    return _map_order(order)
