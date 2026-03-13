"""Authentication router – OTP send/verify, Google auth, profile, logout."""

import random
import os
import logging
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User
from schemas import OtpRequest, OtpVerify, GoogleAuthRequest, AuthResponse, UserOut, UserUpdate
from auth import (
    create_access_token, create_refresh_token, get_current_user_id,
    verify_token, verify_google_id_token,
)
from middleware import sanitize_string, validate_phone_number

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Authentication"])

# In-memory OTP store with expiration
# In production, use Redis or database with proper SMS service
_otp_store: dict[str, dict] = {}

# OTP configuration
OTP_LENGTH = 6
OTP_EXPIRY_MINUTES = 5
MAX_OTP_ATTEMPTS = 3
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
IS_DEVELOPMENT = ENVIRONMENT != "production"

# Rate limiting: track OTP requests per phone
_otp_rate_limit: dict[str, list] = {}
MAX_OTP_REQUESTS_PER_MINUTE = 3


def generate_otp() -> str:
    """Generate a random 6-digit OTP."""
    return ''.join([str(random.randint(0, 9)) for _ in range(OTP_LENGTH)])


def is_otp_expired(otp_data: dict) -> bool:
    """Check if OTP has expired."""
    return datetime.now(timezone.utc) > otp_data['expires_at']


def _check_otp_rate_limit(phone: str) -> None:
    """Check if too many OTP requests have been made."""
    now = datetime.now(timezone.utc)
    cutoff = now - timedelta(minutes=1)

    if phone in _otp_rate_limit:
        # Clean old entries
        _otp_rate_limit[phone] = [t for t in _otp_rate_limit[phone] if t > cutoff]
        if len(_otp_rate_limit[phone]) >= MAX_OTP_REQUESTS_PER_MINUTE:
            raise HTTPException(
                status_code=429,
                detail="Too many OTP requests. Please wait before trying again."
            )
    else:
        _otp_rate_limit[phone] = []

    _otp_rate_limit[phone].append(now)


@router.post("/send-otp")
def send_otp(body: OtpRequest):
    """Send OTP to user's phone number."""
    phone = body.phone.strip()

    # Validate phone number format
    if not validate_phone_number(phone):
        raise HTTPException(status_code=400, detail="Invalid phone number format")

    # Rate limiting
    _check_otp_rate_limit(phone)

    # Generate OTP (use test OTP only in development)
    otp_code = "123456" if IS_DEVELOPMENT else generate_otp()

    # Store OTP with expiration
    _otp_store[phone] = {
        "otp": otp_code,
        "expires_at": datetime.now(timezone.utc) + timedelta(minutes=OTP_EXPIRY_MINUTES),
        "attempts": 0
    }

    # In production, integrate with SMS service here (e.g., Twilio, MSG91)
    if IS_DEVELOPMENT:
        logger.info(f"[DEV] OTP for {phone}: {otp_code}")

    return {
        "message": "OTP sent successfully",
        "txn_id": f"txn_{phone[-4:]}" if len(phone) >= 4 else "txn_unknown",
        "next": "verify",
        "expires_in_minutes": OTP_EXPIRY_MINUTES
    }


@router.post("/verify-otp", response_model=AuthResponse)
def verify_otp(body: OtpVerify, db: Session = Depends(get_db)):
    """Verify OTP and authenticate user."""
    phone = body.phone.strip()

    # Validate phone
    if not validate_phone_number(phone):
        raise HTTPException(status_code=400, detail="Invalid phone number format")

    # Sanitize inputs
    name = sanitize_string(body.name, max_length=100)
    role = body.role.lower().strip()
    if role not in ("farmer", "buyer"):
        raise HTTPException(status_code=400, detail="Role must be 'farmer' or 'buyer'")

    # Get OTP data
    otp_data = _otp_store.get(phone)

    # Validate OTP exists and hasn't expired
    if not otp_data:
        raise HTTPException(status_code=400, detail="OTP not found. Please request a new OTP.")

    if is_otp_expired(otp_data):
        _otp_store.pop(phone, None)
        raise HTTPException(status_code=400, detail="OTP expired. Please request a new OTP.")

    # Check attempts limit
    if otp_data['attempts'] >= MAX_OTP_ATTEMPTS:
        _otp_store.pop(phone, None)
        raise HTTPException(status_code=400, detail="Too many failed attempts. Please request a new OTP.")

    # Verify OTP
    if body.otp != otp_data['otp']:
        otp_data['attempts'] += 1
        remaining_attempts = MAX_OTP_ATTEMPTS - otp_data['attempts']
        raise HTTPException(
            status_code=400,
            detail=f"Invalid OTP. {remaining_attempts} attempts remaining."
        )

    # OTP is valid, proceed with authentication
    user = db.query(User).filter(User.phone == phone).first()

    if user is None:
        # Create new user
        user = User(
            phone=phone,
            name=name if name and name != "User" else "User",
            role=role,
            village=sanitize_string(body.village) if body.village else None,
            district=sanitize_string(body.district) if body.district else None,
            organization=sanitize_string(body.org) if body.org else None,
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        # Update existing user if needed
        if name and name != "User":
            user.name = name
        if role:
            user.role = role
        user.updated_at = datetime.utcnow()
        db.commit()

    # Generate tokens
    token_data = {"sub": user.id, "phone": user.phone, "role": user.role}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    # Clear OTP after successful verification
    _otp_store.pop(phone, None)

    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserOut.model_validate(user),
    )


@router.post("/refresh")
def refresh_access_token(refresh_token: str):
    """Exchange a refresh token for a new access token."""
    payload = verify_token(refresh_token, expected_type="refresh")
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid refresh token")

    new_access = create_access_token({"sub": user_id})
    return {"access_token": new_access, "token_type": "bearer"}


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
        user.name = sanitize_string(body.name, max_length=100)
    if body.village is not None:
        user.village = sanitize_string(body.village, max_length=100)
    if body.district is not None:
        user.district = sanitize_string(body.district, max_length=100)
    if body.org is not None:
        user.organization = sanitize_string(body.org, max_length=150)
    user.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(user)
    return UserOut.model_validate(user)


@router.post("/logout")
def logout():
    return {"message": "Logged out successfully"}


@router.post("/google", response_model=AuthResponse)
def google_auth(body: GoogleAuthRequest, db: Session = Depends(get_db)):
    """Authenticate with Google. Validates ID token server-side. Creates user if not exists."""
    if not body.email:
        raise HTTPException(status_code=400, detail="Email is required for Google authentication.")

    # Verify Google ID token server-side
    google_info = verify_google_id_token(body.google_id_token)

    # If verification returned data, validate email matches
    if google_info is not None:
        if google_info["email"].lower() != body.email.lower():
            raise HTTPException(
                status_code=400,
                detail="Email mismatch between token and request"
            )
        # Use verified data from Google
        verified_name = google_info.get("name", body.name)
        verified_email = google_info["email"]
        profile_image = google_info.get("picture", body.profile_image)
    else:
        # Dev mode fallback – trust the client data
        verified_name = body.name
        verified_email = body.email
        profile_image = body.profile_image

    # Validate role
    role = body.role.lower().strip()
    if role not in ("farmer", "buyer"):
        raise HTTPException(status_code=400, detail="Role must be 'farmer' or 'buyer'")

    # Find or create user by email
    user = db.query(User).filter(User.email == verified_email).first()

    if user is None:
        # Create new user
        user = User(
            email=verified_email,
            phone=None,
            name=sanitize_string(verified_name, max_length=100),
            role=role,
            village=sanitize_string(body.village) if body.village else None,
            district=sanitize_string(body.district) if body.district else None,
            organization=sanitize_string(body.org) if body.org else None,
            profile_image=profile_image,
            is_verified=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
    else:
        # Update profile image and name if changed
        if verified_name and verified_name != "User":
            user.name = verified_name
        if profile_image:
            user.profile_image = profile_image
        if role:
            user.role = role
        user.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(user)

    # Generate tokens
    token_data = {"sub": user.id, "email": user.email, "role": user.role}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserOut.model_validate(user),
    )
