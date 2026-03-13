"""Crops router – CRUD for grain listings."""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional

from database import get_db
from models import Crop
from schemas import CropCreate, CropUpdate, CropOut
from auth import get_current_user_id

router = APIRouter(prefix="/crops", tags=["Crops"])


@router.get("/", response_model=list[CropOut])
def list_crops(
    category: Optional[str] = None,
    search: Optional[str] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Crop).filter(Crop.is_available == True)
    if category:
        query = query.filter(Crop.category == category)
    if search:
        query = query.filter(Crop.name.ilike(f"%{search}%"))
    crops = query.order_by(Crop.created_at.desc()).offset(skip).limit(limit).all()

    out = []
    for crop in crops:
        c = CropOut.model_validate(crop)
        if crop.farmer:
            c.farmer_name = crop.farmer.name
            c.farmer_phone = crop.farmer.phone
        out.append(c)
    return out


@router.get("/my-listings", response_model=list[CropOut])
def my_listings(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crops = db.query(Crop).filter(Crop.farmer_id == user_id).order_by(Crop.created_at.desc()).all()
    out = []
    for crop in crops:
        c = CropOut.model_validate(crop)
        if crop.farmer:
            c.farmer_name = crop.farmer.name
            c.farmer_phone = crop.farmer.phone
        out.append(c)
    return out


@router.get("/{crop_id}", response_model=CropOut)
def get_crop(crop_id: str, db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found")
    c = CropOut.model_validate(crop)
    if crop.farmer:
        c.farmer_name = crop.farmer.name
        c.farmer_phone = crop.farmer.phone
    return c


@router.post("/", response_model=CropOut, status_code=201)
def create_crop(body: CropCreate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = Crop(
        farmer_id=user_id,
        name=body.name,
        variety=body.variety,
        description=body.description,
        category=body.category,
        price_per_kg=body.price_per_kg,
        stock_kg=body.stock_kg,
        min_order_kg=body.min_order_kg,
        unit=body.unit,
        image_url=body.image_url,
        location=body.location,
        last_price_update=datetime.utcnow(),
    )
    db.add(crop)
    db.commit()
    db.refresh(crop)
    return CropOut.model_validate(crop)


@router.put("/{crop_id}", response_model=CropOut)
def update_crop(crop_id: str, body: CropUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id, Crop.farmer_id == user_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found or not owned by you")

    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(crop, field, value)
    if body.price_per_kg is not None:
        crop.last_price_update = datetime.utcnow()
    crop.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(crop)
    c = CropOut.model_validate(crop)
    if crop.farmer:
        c.farmer_name = crop.farmer.name
        c.farmer_phone = crop.farmer.phone
    return c


@router.delete("/{crop_id}", status_code=204)
def delete_crop(crop_id: str, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    crop = db.query(Crop).filter(Crop.id == crop_id, Crop.farmer_id == user_id).first()
    if crop is None:
        raise HTTPException(status_code=404, detail="Crop not found or not owned by you")
    db.delete(crop)
    db.commit()
