"""SQLAlchemy ORM models for Farmaa."""

import uuid
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Float, Integer, Boolean, DateTime, Text, ForeignKey
)
from sqlalchemy.orm import relationship
from database import Base


def new_id() -> str:
    return str(uuid.uuid4())


class OtpCode(Base):
    __tablename__ = "otp_codes"

    id = Column(String, primary_key=True, default=new_id)
    phone = Column(String(15), nullable=False, index=True)
    code = Column(String(10), nullable=False)
    used = Column(Boolean, default=False)
    ip_address = Column(String(50))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    expires_at = Column(DateTime, nullable=False)

class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=new_id)
    phone = Column(String(15), unique=True, nullable=True, index=True)
    email = Column(String(255), unique=True, nullable=True, index=True)
    name = Column(String(100), nullable=False)
    role = Column(String(10), nullable=False, default="buyer")
    village = Column(String(100))
    district = Column(String(100))
    organization = Column(String(150))
    profile_image = Column(String(500))
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    crops = relationship("Crop", back_populates="farmer", lazy="joined")


class Crop(Base):
    __tablename__ = "crops"

    id = Column(String, primary_key=True, default=new_id)
    farmer_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    name = Column(String(100), nullable=False)
    variety = Column(String(100))
    description = Column(Text)
    category = Column(String(50), default="Other")
    price_per_kg = Column(Float, nullable=False)
    stock_kg = Column(Float, nullable=False, default=0)
    min_order_kg = Column(Float, default=50)
    unit = Column(String(10), default="kg")
    status = Column(String(20), default="approved")
    is_available = Column(Boolean, default=True)
    image_url = Column(String(500))
    location = Column(String(200))
    last_price_update = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    farmer = relationship("User", back_populates="crops")


class Order(Base):
    __tablename__ = "orders"

    id = Column(String, primary_key=True, default=new_id)
    buyer_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    farmer_id = Column(String, ForeignKey("users.id"), nullable=False, index=True)
    crop_id = Column(String, ForeignKey("crops.id"), nullable=False)
    quantity_kg = Column(Float, nullable=False)
    total_amount = Column(Float, nullable=False)
    delivery_address = Column(Text)
    status = Column(String(20), default="pending")
    payment_id = Column(String(100))
    razorpay_order_id = Column(String(100))
    razorpay_signature = Column(String(200))
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    buyer = relationship("User", foreign_keys=[buyer_id], lazy="joined")
    farmer_ = relationship("User", foreign_keys=[farmer_id], lazy="joined")
    crop = relationship("Crop", lazy="joined")


class MarketPrice(Base):
    __tablename__ = "market_prices"

    id = Column(String, primary_key=True, default=new_id)
    crop_name = Column(String(100), nullable=False, index=True)
    category = Column(String(50))
    price_per_kg = Column(Float, nullable=False)
    market_name = Column(String(150))
    source = Column(String(100), default="manual")
    recorded_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
