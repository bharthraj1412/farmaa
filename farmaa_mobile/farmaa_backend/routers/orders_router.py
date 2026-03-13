"""Orders router – create, list, update status."""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime

from database import get_db
from models import Order, Crop, User
from schemas import OrderCreate, OrderStatusUpdate, OrderOut
from auth import get_current_user_id

router = APIRouter(prefix="/orders", tags=["Orders"])


@router.post("/", response_model=OrderOut, status_code=201)
def create_order(body: OrderCreate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == body.crop_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found")
    if not crop.is_available:
        raise HTTPException(status_code=400, detail="Crop is not available")
    if body.quantity_kg > crop.stock_kg:
        raise HTTPException(status_code=400, detail="Insufficient stock")

    total = body.quantity_kg * crop.price_per_kg

    order = Order(
        buyer_id=user_id,
        farmer_id=crop.farmer_id,
        crop_id=crop.id,
        quantity_kg=body.quantity_kg,
        total_amount=total,
        delivery_address=body.delivery_address,
        payment_id=body.payment_id,
    )
    db.add(order)

    crop.stock_kg -= body.quantity_kg
    if crop.stock_kg <= 0:
        crop.is_available = False
        crop.status = "sold_out"

    db.commit()
    db.refresh(order)

    out = OrderOut.model_validate(order)
    out.crop_name = crop.name
    return out


@router.get("/my-orders", response_model=list[OrderOut])
def my_orders(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    orders = db.query(Order).filter(
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id)
    ).order_by(Order.created_at.desc()).all()

    out = []
    for order in orders:
        o = OrderOut.model_validate(order)
        if order.crop:
            o.crop_name = order.crop.name
        if order.buyer:
            o.buyer_name = order.buyer.name
        if order.farmer_:
            o.farmer_name = order.farmer_.name
        out.append(o)
    return out


@router.get("/{order_id}", response_model=OrderOut)
def get_order(order_id: str, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    order = db.query(Order).filter(
        Order.id == order_id,
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id),
    ).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    o = OrderOut.model_validate(order)
    if order.crop:
        o.crop_name = order.crop.name
    return o


@router.patch("/{order_id}/status", response_model=OrderOut)
def update_order_status(order_id: str, body: OrderStatusUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    valid_statuses = {"pending", "confirmed", "shipped", "delivered", "cancelled"}
    if body.status not in valid_statuses:
        raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of: {valid_statuses}")

    order = db.query(Order).filter(
        Order.id == order_id,
        or_(Order.buyer_id == user_id, Order.farmer_id == user_id),
    ).first()
    if order is None:
        raise HTTPException(status_code=404, detail="Order not found")

    order.status = body.status
    order.updated_at = datetime.utcnow()

    if body.status == "cancelled":
        crop = db.query(Crop).filter(Crop.id == order.crop_id).first()
        if crop:
            crop.stock_kg += order.quantity_kg
            crop.is_available = True
            if crop.status == "sold_out":
                crop.status = "approved"

    db.commit()
    db.refresh(order)
    o = OrderOut.model_validate(order)
    if order.crop:
        o.crop_name = order.crop.name
    return o
