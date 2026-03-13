"""Database connection module for Supabase PostgreSQL.

Compatible with both traditional servers (Render) and serverless (Vercel).
"""

import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Handle Render's postgres:// vs postgresql:// URL format
if DATABASE_URL:
    DATABASE_URL = DATABASE_URL.strip()
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)


class Base(DeclarativeBase):
    pass


def _create_engine():
    """Lazy engine creation – only connects when first DB call is made."""
    if not DATABASE_URL:
        return None
    return create_engine(
        DATABASE_URL,
        pool_size=1,
        max_overflow=2,
        pool_pre_ping=True,
        pool_recycle=60,
        connect_args={"connect_timeout": 10},
    )


# Lazy globals - created on first use
_engine = None
_SessionLocal = None


def get_engine():
    global _engine
    if _engine is None:
        _engine = _create_engine()
    return _engine


def get_session_factory():
    global _SessionLocal
    if _SessionLocal is None:
        eng = get_engine()
        if eng is not None:
            _SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=eng)
    return _SessionLocal


# Keep backward-compatible exports
engine = None  # Will be set lazily
SessionLocal = None  # Will be set lazily


def get_db():
    """FastAPI dependency – yields a database session."""
    factory = get_session_factory()
    if factory is None:
        raise Exception("Database not configured. Set DATABASE_URL environment variable.")
    db = factory()
    try:
        yield db
    finally:
        db.close()
