"""Security middleware and role-based access control helpers for Farmaa API."""

import uuid
import time
import logging
from functools import wraps
from fastapi import Request, HTTPException, Depends, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from auth import get_current_user_id
from database import get_db
from models import User
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)


# ── Security Headers Middleware ──────────────────────────────────────────────

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Adds security headers to all responses."""

    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate"
        response.headers["Pragma"] = "no-cache"
        return response


# ── Request Logging Middleware ───────────────────────────────────────────────

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Logs each request with a unique request ID for traceability."""

    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())[:8]
        request.state.request_id = request_id
        start_time = time.time()

        response = await call_next(request)

        duration_ms = round((time.time() - start_time) * 1000, 2)
        logger.info(
            f"[{request_id}] {request.method} {request.url.path} "
            f"→ {response.status_code} ({duration_ms}ms)"
        )
        response.headers["X-Request-ID"] = request_id
        return response


# ── Role Guard Dependency ────────────────────────────────────────────────────

def require_role(*allowed_roles: str):
    """FastAPI dependency that checks if the authenticated user has one of the allowed roles.
    
    Usage:
        @router.get("/admin-only", dependencies=[Depends(require_role("admin"))])
        def admin_endpoint(): ...
    """
    async def role_checker(
        user_id: str = Depends(get_current_user_id),
        db: Session = Depends(get_db),
    ):
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required role: {', '.join(allowed_roles)}",
            )
        return user
    return role_checker


# ── Input Sanitization Helpers ───────────────────────────────────────────────

def sanitize_string(value: str, max_length: int = 500) -> str:
    """Sanitize a string input by stripping dangerous characters and limiting length."""
    if not value:
        return value
    # Strip leading/trailing whitespace
    value = value.strip()
    # Truncate to max length
    value = value[:max_length]
    # Remove null bytes
    value = value.replace('\x00', '')
    return value


def sanitize_search_query(query: str) -> str:
    """Sanitize search query to prevent SQL injection via LIKE patterns.
    
    SQLAlchemy parameterizes queries, but we still sanitize LIKE wildcards
    to prevent pattern-based abuse.
    """
    if not query:
        return query
    query = sanitize_string(query, max_length=100)
    # Escape SQL LIKE special characters
    query = query.replace('\\', '\\\\')
    query = query.replace('%', '\\%')
    query = query.replace('_', '\\_')
    return query


def validate_phone_number(phone: str) -> bool:
    """Basic phone number validation."""
    import re
    # Allow + prefix, then 7-15 digits
    pattern = r'^\+?[0-9]{7,15}$'
    return bool(re.match(pattern, phone.strip()))
