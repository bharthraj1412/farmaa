"""Pydantic schemas (request/response models) with field validation."""

import re
from pydantic import BaseModel, Field, field_validator
from typing import List, Optional
from datetime import datetime


# ── Auth ──
class OtpRequest(BaseModel):
    phone: str = Field(..., min_length=7, max_length=15, description="Phone number (7-15 digits)")

    @field_validator("phone")
    @classmethod
    def validate_phone(cls, v: str) -> str:
        v = v.strip()
        if not re.match(r'^\+?[0-9]{7,15}$', v):
            raise ValueError("Invalid phone number format")
        return v


class OtpVerify(BaseModel):
    phone: str
    otp: str = Field(..., min_length=6, max_length=6, pattern=r'^\d{6}$')
    role: str = Field(default="buyer", pattern=r'^(farmer|buyer)$')
    name: str = Field(default="User", max_length=100)
    village: Optional[str] = Field(default=None, max_length=100)
    district: Optional[str] = Field(default=None, max_length=100)
    org: Optional[str] = Field(default=None, max_length=150)


class GoogleAuthRequest(BaseModel):
    google_id_token: str = Field(..., min_length=10, description="Google ID token for server-side verification")
    email: str = Field(..., description="Google email address")
    name: str = Field(default="User", max_length=100)
    profile_image: Optional[str] = None
    role: str = Field(default="buyer", pattern=r'^(farmer|buyer)$')
    village: Optional[str] = Field(default=None, max_length=100)
    district: Optional[str] = Field(default=None, max_length=100)
    org: Optional[str] = Field(default=None, max_length=150)

    @field_validator("email")
    @classmethod
    def validate_email(cls, v: str) -> str:
        v = v.strip().lower()
        if not re.match(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', v):
            raise ValueError("Invalid email format")
        return v


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: Optional[str] = None
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
    name: Optional[str] = Field(default=None, max_length=100)
    village: Optional[str] = Field(default=None, max_length=100)
    district: Optional[str] = Field(default=None, max_length=100)
    org: Optional[str] = Field(default=None, max_length=150)


# ── Crops ──
class CropCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    variety: Optional[str] = Field(default=None, max_length=100)
    description: Optional[str] = Field(default=None, max_length=1000)
    category: str = Field(default="Other")
    price_per_kg: float = Field(..., gt=0, le=100000, description="Price per kg in INR")
    stock_kg: float = Field(default=0, ge=0, le=1000000, description="Available stock in kg")
    min_order_kg: Optional[float] = Field(default=50, ge=0)
    unit: str = Field(default="kg", max_length=10)
    image_url: Optional[str] = Field(default=None, max_length=500)
    location: Optional[str] = Field(default=None, max_length=200)

    @field_validator("category")
    @classmethod
    def validate_category(cls, v: str) -> str:
        valid = {"Rice", "Wheat", "Millet", "Barley", "Sorghum", "Maize", "Pulses", "Other"}
        if v not in valid:
            raise ValueError(f"Invalid category. Must be one of: {valid}")
        return v


class CropUpdate(BaseModel):
    name: Optional[str] = Field(default=None, max_length=100)
    variety: Optional[str] = Field(default=None, max_length=100)
    description: Optional[str] = Field(default=None, max_length=1000)
    category: Optional[str] = None
    price_per_kg: Optional[float] = Field(default=None, gt=0, le=100000)
    stock_kg: Optional[float] = Field(default=None, ge=0, le=1000000)
    min_order_kg: Optional[float] = Field(default=None, ge=0)
    image_url: Optional[str] = Field(default=None, max_length=500)
    location: Optional[str] = Field(default=None, max_length=200)

    @field_validator("category")
    @classmethod
    def validate_category(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        valid = {"Rice", "Wheat", "Millet", "Barley", "Sorghum", "Maize", "Pulses", "Other"}
        if v not in valid:
            raise ValueError(f"Invalid category. Must be one of: {valid}")
        return v


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
    updated_at: Optional[datetime] = None
    farmer_name: Optional[str] = None
    farmer_phone: Optional[str] = None
    farmer_verified: bool = False
    farmer_district: Optional[str] = None
    images: List[str] = []

    class Config:
        from_attributes = True


# ── Orders ──
class OrderCreate(BaseModel):
    crop_id: str = Field(..., min_length=1)
    quantity_kg: float = Field(..., gt=0, le=1000000, description="Order quantity in kg")
    delivery_address: Optional[str] = Field(default=None, max_length=500)
    payment_id: Optional[str] = None
    razorpay_order_id: Optional[str] = None
    razorpay_signature: Optional[str] = None


class OrderStatusUpdate(BaseModel):
    status: str

    @field_validator("status")
    @classmethod
    def validate_status(cls, v: str) -> str:
        valid = {"pending", "confirmed", "processing", "shipped", "delivered", "cancelled"}
        if v not in valid:
            raise ValueError(f"Invalid status. Must be one of: {valid}")
        return v


class OrderOut(BaseModel):
    id: str
    buyer_id: str
    farmer_id: str
    crop_id: str
    quantity_kg: float
    total_amount: float
    delivery_address: Optional[str] = None
    status: str
    payment_status: str = "pending"
    payment_id: Optional[str] = None
    razorpay_order_id: Optional[str] = None
    razorpay_signature: Optional[str] = None
    estimated_delivery: Optional[datetime] = None
    tax_amount: Optional[float] = 0.0
    price_per_kg: Optional[float] = 0.0
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    crop_name: Optional[str] = None
    crop_category: Optional[str] = None
    crop_image: Optional[str] = None
    buyer_name: Optional[str] = None
    buyer_phone: Optional[str] = None
    farmer_name: Optional[str] = None
    farmer_phone: Optional[str] = None

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
