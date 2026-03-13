"""Authentication router – OTP send/verify, profile, logout."""

import random
import os
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import OtpRequest, OtpVerify, GoogleAuthRequest, AuthResponse, UserOut, UserUpdate
from auth import create_access_token, get_current_user_id

router = APIRouter(prefix="/auth", tags=["Authentication"])

# In-memory OTP store with expiration (for development)
# In production, use Redis or database with proper SMS service
_otp_store: dict[str, dict] = {}

# OTP configuration
OTP_LENGTH = 6
OTP_EXPIRY_MINUTES = 5
IS_DEVELOPMENT = os.getenv("ENVIRONMENT", "development") == "development"


def generate_otp() -> str:
    """Generate a random 6-digit OTP."""
    return ''.join([str(random.randint(0, 9)) for _ in range(OTP_LENGTH)])


def is_otp_expired(otp_data: dict) -> bool:
    """Check if OTP has expired."""
    return datetime.now(timezone.utc) > otp_data['expires_at']


@router.post("/send-otp")
def send_otp(body: OtpRequest):
    """Send OTP to user's phone number."""
    # Generate OTP
    otp_code = "123456" if IS_DEVELOPMENT else generate_otp()
    
    # Store OTP with expiration
    _otp_store[body.phone] = {
        "otp": otp_code,
        "expires_at": datetime.now(timezone.utc) + timedelta(minutes=OTP_EXPIRY_MINUTES),
        "attempts": 0
    }
    
    # In production, integrate with SMS service here
    # For development, we'll log it (remove in production)
    if IS_DEVELOPMENT:
        print(f"[DEV] OTP for {body.phone}: {otp_code}")
    
    return {
        "message": "OTP sent successfully",
        "txn_id": f"txn_{body.phone[-4:]}" if len(body.phone) >= 4 else "txn_unknown",
        "next": "verify",
        "expires_in_minutes": OTP_EXPIRY_MINUTES
    }


@router.post("/verify-otp", response_model=AuthResponse)
def verify_otp(body: OtpVerify, db: Session = Depends(get_db)):
    """Verify OTP and authenticate user."""
    # Get OTP data
    otp_data = _otp_store.get(body.phone)
    
    # Validate OTP exists and hasn't expired
    if not otp_data:
        raise HTTPException(status_code=400, detail="OTP not found. Please request a new OTP.")
    
    if is_otp_expired(otp_data):
        _otp_store.pop(body.phone, None)
        raise HTTPException(status_code=400, detail="OTP expired. Please request a new OTP.")
    
    # Check attempts limit (max 3 attempts)
    if otp_data['attempts'] >= 3:
        _otp_store.pop(body.phone, None)
        raise HTTPException(status_code=400, detail="Too many failed attempts. Please request a new OTP.")
    
    # Verify OTP
    if body.otp != otp_data['otp']:
        otp_data['attempts'] += 1
        remaining_attempts = 3 - otp_data['attempts']
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid OTP. {remaining_attempts} attempts remaining."
        )

    # OTP is valid, proceed with authentication
    user = db.query(User).filter(User.phone == body.phone).first()

    if user is None:
        # Create new user
        user = User(
            phone=body.phone,
            name=body.name,
            role=body.role,
            village=body.village,
            district=body.district,
            organization=body.org,
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        # Update existing user if needed
        if body.name and body.name != "User":
            user.name = body.name
        if body.role:
            user.role = body.role
        db.commit()

    # Generate JWT token
    token = create_access_token({"sub": user.id, "phone": user.phone, "role": user.role})
    
    # Clear OTP after successful verification
    _otp_store.pop(body.phone, None)

    return AuthResponse(access_token=token, user=UserOut.model_validate(user))


@router.get("/me", response_model=UserOut)
def get_profile(user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return UserOut.model_validate(user)


@router.patch("/me", response_model=UserOut)
def update_profile(body: UserUpdate, user_id: str = Depends(get_current_user_id), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    if body.name is not None:
        user.name = body.name
    if body.village is not None:
        user.village = body.village
    if body.district is not None:
        user.district = body.district
    if body.org is not None:
        user.organization = body.org
    user.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)


@router.post("/logout")
def logout():
    return {"message": "Logged out successfully"}


@router.post("/google", response_model=AuthResponse)
def google_auth(body: GoogleAuthRequest, db: Session = Depends(get_db)):
    """Authenticate with Google. Creates user if not exists."""
    if not body.email:
        raise HTTPException(status_code=400, detail="Email is required for Google authentication.")
    
    # Find or create user by email
    user = db.query(User).filter(User.email == body.email).first()
    
    if user is None:
        # Create new user
        user = User(
            email=body.email,
            phone=None,
            name=body.name,
            role=body.role,
            village=body.village,
            district=body.district,
            organization=body.org,
            profile_image=body.profile_image,
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        # Update profile image and name if changed
        if body.name and body.name != "User":
            user.name = body.name
        if body.profile_image:
            user.profile_image = body.profile_image
        if body.role:
            user.role = body.role
        db.commit()
        db.refresh(user)

    # Generate JWT token
    token = create_access_token({"sub": user.id, "email": user.email, "role": user.role})
    
    return AuthResponse(access_token=token, user=UserOut.model_validate(user))
