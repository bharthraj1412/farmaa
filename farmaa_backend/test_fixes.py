#!/usr/bin/env python3
"""
Test script to verify Farmaa backend fixes.
Run this script to check if all fixes are working correctly.
"""

import sys
import os
import requests
import time
from datetime import datetime, timezone

def test_imports():
    """Test if all modules import correctly."""
    print("🔍 Testing imports...")
    try:
        from database import engine, create_tables, check_database_health
        from models import User, Crop, Order, MarketPrice
        from routers.auth_router import router as auth_router
        from main import app
        print("✅ All imports successful")
        return True
    except Exception as e:
        print(f"❌ Import failed: {e}")
        return False

def test_database_connection():
    """Test database connection and health."""
    print("\n🔍 Testing database connection...")
    try:
        from database import check_database_health
        is_healthy, message = check_database_health()
        if is_healthy:
            print("✅ Database connection healthy")
            return True
        else:
            print(f"❌ Database connection failed: {message}")
            return False
    except Exception as e:
        print(f"❌ Database test failed: {e}")
        return False

def test_otp_functionality():
    """Test OTP generation and validation logic."""
    print("\n🔍 Testing OTP functionality...")
    try:
        from routers.auth_router import generate_otp, is_otp_expired
        from datetime import datetime, timedelta
        
        # Test OTP generation
        otp = generate_otp()
        if len(otp) == 6 and otp.isdigit():
            print("✅ OTP generation works")
        else:
            print("❌ OTP generation failed")
            return False
        
        # Test OTP expiration
        otp_data = {
            "otp": "123456",
            "expires_at": datetime.now(timezone.utc) + timedelta(minutes=5)
        }
        if not is_otp_expired(otp_data):
            print("✅ OTP expiration logic works")
        else:
            print("❌ OTP expiration logic failed")
            return False
            
        return True
    except Exception as e:
        print(f"❌ OTP test failed: {e}")
        return False

def test_environment_variables():
    """Test if environment variables are properly configured."""
    print("\n🔍 Testing environment variables...")
    try:
        from database import DATABASE_URL
        from auth import SECRET_KEY
        
        if DATABASE_URL:
            print("✅ DATABASE_URL is set")
        else:
            print("❌ DATABASE_URL is not set")
            return False
            
        if SECRET_KEY and SECRET_KEY != "farmaa-dev-secret":
            print("✅ SECRET_KEY is configured")
        else:
            print("⚠️  SECRET_KEY is using default value (OK for development)")
            
        return True
    except Exception as e:
        print(f"❌ Environment test failed: {e}")
        return False

def test_api_endpoints():
    """Test if API endpoints are accessible."""
    print("\n🔍 Testing API endpoints...")
    try:
        # Test health endpoint
        response = requests.get("http://localhost:10000/health", timeout=5)
        if response.status_code == 200:
            print("✅ Health endpoint accessible")
        else:
            print(f"❌ Health endpoint failed: {response.status_code}")
            return False
            
        # Test database health endpoint
        response = requests.get("http://localhost:10000/health/db", timeout=5)
        if response.status_code == 200:
            print("✅ Database health endpoint accessible")
        else:
            print(f"❌ Database health endpoint failed: {response.status_code}")
            return False
            
        return True
    except requests.exceptions.ConnectionError:
        print("⚠️  API server not running (start with: uvicorn main:app --host 0.0.0.0 --port 10000)")
        return False
    except Exception as e:
        print(f"❌ API test failed: {e}")
        return False

def main():
    """Run all tests and provide summary."""
    print("🚀 Farmaa Backend Fix Verification")
    print("=" * 50)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    tests = [
        ("Imports", test_imports),
        ("Database Connection", test_database_connection),
        ("OTP Functionality", test_otp_functionality),
        ("Environment Variables", test_environment_variables),
        ("API Endpoints", test_api_endpoints),
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test crashed: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 Test Summary:")
    print()
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:.<30} {status}")
        if result:
            passed += 1
    
    print()
    print(f"Overall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Your Farmaa backend is ready.")
        return 0
    else:
        print("⚠️  Some tests failed. Please check the issues above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
