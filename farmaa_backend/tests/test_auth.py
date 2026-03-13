import pytest
from models import OtpCode, User

def test_send_otp_creates_record_and_respects_rate_limit(client, setup_db):
    db = setup_db
    response = client.post("/auth/send-otp", json={"phone": "9876543210"})
    assert response.status_code == 200
    assert response.json()["message"] == "OTP sent successfully"
    
    otp_record = db.query(OtpCode).filter(OtpCode.phone == "9876543210").first()
    assert otp_record is not None
    assert otp_record.used == False
    
    client.post("/auth/send-otp", json={"phone": "9876543210"})
    client.post("/auth/send-otp", json={"phone": "9876543210"})
    
    response_4 = client.post("/auth/send-otp", json={"phone": "9876543210"})
    assert response_4.status_code == 429

def test_verify_otp_returns_token_and_marks_used(client, setup_db):
    db = setup_db
    from datetime import datetime, timedelta, timezone
    otp_entry = OtpCode(
        phone="9999999999",
        code="123456",
        created_at=datetime.now(timezone.utc),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=5)
    )
    db.add(otp_entry)
    db.commit()
    
    response = client.post("/auth/verify-otp", json={
        "phone": "9999999999",
        "otp": "123456",
        "role": "buyer",
        "name": "Test User"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["user"]["phone"] == "9999999999"
    
    used_otp = db.query(OtpCode).filter(OtpCode.phone == "9999999999", OtpCode.code == "123456").first()
    assert used_otp.used == True
