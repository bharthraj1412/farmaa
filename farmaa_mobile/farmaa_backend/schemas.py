"""Pydantic schemas (request/response models)."""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


# ── Auth ──
class OtpRequest(BaseModel):
    phone: str

class OtpVerify(BaseModel):
    phone: str
    otp: str
    role: str = "buyer"
    name: str = "User"
    village: Optional[str] = None
    district: Optional[str] = None
    org: Optional[str] = None

class GoogleAuthRequest(BaseModel):
    google_id_token: str
    email: str
    name: str = "User"
    profile_image: Optional[str] = None
    role: str = "buyer"
    village: Optional[str] = None
    district: Optional[str] = None
    org: Optional[str] = None

class AuthResponse(BaseModel):
    access_token: str
    user: "UserOut"

class UserOut(BaseModel):
    id: str
    phone: Optional[str] = None
    email: Optional[str] = None
    name: str
    role: str
    village: Optional[str] = None
    district: Optional[str] = None
    organization: Optional[str] = None
    profile_image: Optional[str] = None
    is_verified: bool = False
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    name: Optional[str] = None
    village: Optional[str] = None
    district: Optional[str] = None
    org: Optional[str] = None


# ── Crops ──
class CropCreate(BaseModel):
    name: str
    variety: Optional[str] = None
    description: Optional[str] = None
    category: str = "Other"
    price_per_kg: float
    stock_kg: float = 0
    min_order_kg: Optional[float] = 50
    unit: str = "kg"
    image_url: Optional[str] = None
    location: Optional[str] = None

class CropUpdate(BaseModel):
    name: Optional[str] = None
    variety: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price_per_kg: Optional[float] = None
    stock_kg: Optional[float] = None
    min_order_kg: Optional[float] = None
    image_url: Optional[str] = None
    location: Optional[str] = None

class CropOut(BaseModel):
    id: str
    farmer_id: str
    name: str
    variety: Optional[str] = None
    description: Optional[str] = None
    category: str
    price_per_kg: float
    stock_kg: float
    min_order_kg: Optional[float] = None
    unit: str = "kg"
    status: str
    is_available: bool
    image_url: Optional[str] = None
    location: Optional[str] = None
    last_price_update: Optional[datetime] = None
    created_at: Optional[datetime] = None
    farmer_name: Optional[str] = None
    farmer_phone: Optional[str] = None

    class Config:
        from_attributes = True


# ── Orders ──
class OrderCreate(BaseModel):
    crop_id: str
    quantity_kg: float
    delivery_address: Optional[str] = None
    payment_id: Optional[str] = None

class OrderStatusUpdate(BaseModel):
    status: str

class OrderOut(BaseModel):
    id: str
    buyer_id: str
    farmer_id: str
    crop_id: str
    quantity_kg: float
    total_amount: float
    delivery_address: Optional[str] = None
    status: str
    payment_id: Optional[str] = None
    created_at: Optional[datetime] = None
    crop_name: Optional[str] = None
    buyer_name: Optional[str] = None
    farmer_name: Optional[str] = None

    class Config:
        from_attributes = True


# ── Market Prices ──
class MarketPriceOut(BaseModel):
    id: str
    crop_name: str
    category: Optional[str] = None
    price_per_kg: float
    market_name: Optional[str] = None
    source: Optional[str] = None
    recorded_at: Optional[datetime] = None

    class Config:
        from_attributes = True
