"""Crops router – CRUD for grain listings with input validation."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime, timezone
from typing import Optional

from database import get_db
from models import Crop, User
from schemas import CropCreate, CropUpdate, CropOut, CropListResponse
from auth import get_current_user_id
from middleware import sanitize_string, sanitize_search_query

router = APIRouter(prefix="/crops", tags=["Crops"])

def _map_crop(crop) -> CropOut:
    """Helper to map Crop model to CropOut schema with joined farmer info."""
    c = CropOut.model_validate(crop)
    if crop.farmer:
        c.farmer_name = crop.farmer.name
        c.farmer_phone = crop.farmer.phone
        c.farmer_verified = getattr(crop.farmer, 'is_verified', False)
        c.farmer_district = getattr(crop.farmer, 'district', None)
    if crop.image_url:
        c.images = [crop.image_url]
    return c


@router.get("", response_model=CropListResponse)
@router.get("/", response_model=CropListResponse, include_in_schema=False)
def list_crops(
    category: Optional[str] = None,
    search: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Crop).filter(Crop.is_available == True)
    if category:
        # Validate category against known values
        valid_categories = {"Rice", "Wheat", "Millet", "Barley", "Sorghum", "Maize", "Pulses", "Other"}
        if category not in valid_categories:
            raise HTTPException(status_code=400, detail=f"Invalid category. Must be one of: {valid_categories}")
        query = query.filter(Crop.category == category)
    if search:
        # Sanitize search input to prevent LIKE pattern abuse
        safe_search = sanitize_search_query(search)
        query = query.filter(Crop.name.ilike(f"%{safe_search}%"))
    total = query.count()
    crops = query.order_by(Crop.created_at.desc()).offset(skip).limit(limit).all()

    return {
        "total": total,
        "items": [_map_crop(c) for c in crops]
    }


@router.get("/my-listings", response_model=list[CropOut])
def my_listings(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crops = db.query(Crop).filter(Crop.farmer_id == user_id).order_by(Crop.created_at.desc()).all()
    return [_map_crop(c) for c in crops]


@router.get("/{crop_id}", response_model=CropOut)
def get_crop(crop_id: str, db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found")
    return _map_crop(crop)


@router.post("", response_model=CropOut, status_code=201)
@router.post("/", response_model=CropOut, status_code=201, include_in_schema=False)
def create_crop(body: CropCreate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    # Verify user is a farmer
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    if user.role != "farmer" and user.role != "admin":
        raise HTTPException(status_code=403, detail="Only farmers can create crop listings")

    # Validate price and stock
    if body.price_per_kg <= 0:
        raise HTTPException(status_code=400, detail="Price must be a positive number")
    if body.stock_kg < 0:
        raise HTTPException(status_code=400, detail="Stock cannot be negative")
    if body.price_per_kg > 100000:
        raise HTTPException(status_code=400, detail="Price seems unreasonably high. Please verify.")

    crop = Crop(
        farmer_id=user_id,
        name=sanitize_string(body.name, max_length=100),
        variety=sanitize_string(body.variety, max_length=100) if body.variety else None,
        description=sanitize_string(body.description, max_length=1000) if body.description else None,
        category=body.category,
        price_per_kg=body.price_per_kg,
        stock_kg=body.stock_kg,
        min_order_kg=body.min_order_kg,
        unit=body.unit,
        image_url=body.image_url,
        location=sanitize_string(body.location, max_length=200) if body.location else None,
        last_price_update=datetime.now(timezone.utc),
    )
    db.add(crop)
    db.commit()
    db.refresh(crop)
    return _map_crop(crop)


@router.put("/{crop_id}", response_model=CropOut)
def update_crop(crop_id: str, body: CropUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id, Crop.farmer_id == user_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found or not owned by you")

    # Validate price if provided
    if body.price_per_kg is not None:
        if body.price_per_kg <= 0:
            raise HTTPException(status_code=400, detail="Price must be a positive number")
        if body.price_per_kg > 100000:
            raise HTTPException(status_code=400, detail="Price seems unreasonably high. Please verify.")

    # Validate stock if provided
    if body.stock_kg is not None and body.stock_kg < 0:
        raise HTTPException(status_code=400, detail="Stock cannot be negative")

    update_data = body.model_dump(exclude_unset=True)
    # Sanitize string fields
    for field in ['name', 'variety', 'description', 'location']:
        if field in update_data and update_data[field] is not None:
            update_data[field] = sanitize_string(update_data[field])

    for field, value in update_data.items():
        setattr(crop, field, value)

    if body.price_per_kg is not None:
        crop.last_price_update = datetime.now(timezone.utc)
    crop.updated_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(crop)
    return _map_crop(crop)


@router.delete("/{crop_id}", status_code=204)
def delete_crop(crop_id: str, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id, Crop.farmer_id == user_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found or not owned by you")
    db.delete(crop)
    db.commit()
