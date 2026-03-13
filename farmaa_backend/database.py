"""Database connection module for Supabase PostgreSQL."""

import os
import logging
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from sqlalchemy.exc import SQLAlchemyError

load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DATABASE_URL = os.getenv("DATABASE_URL")

# Handle Render's postgres:// vs postgresql:// URL format
if DATABASE_URL:
    DATABASE_URL = DATABASE_URL.strip()
    if DATABASE_URL.startswith("postgres://"):
        DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

if DATABASE_URL:
    try:
        engine = create_engine(
            DATABASE_URL,
            pool_size=5,
            max_overflow=10,
            pool_pre_ping=True,
            pool_recycle=300,
            echo=False,  # Set to True for SQL logging in development
        )
        SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        
        # Test database connection
        def test_connection():
            try:
                with engine.connect() as connection:
                    result = connection.execute(text("SELECT 1"))
                    logger.info("[Farmaa] Database connection successful ✓")
                    return True
            except SQLAlchemyError as e:
                logger.error(f"[Farmaa] Database connection failed: {e}")
                return False
        
        # Test connection on startup
        test_connection()
        
    except Exception as e:
        logger.error(f"[Farmaa] Failed to create database engine: {e}")
        engine = None
        SessionLocal = None
else:
    engine = None
    SessionLocal = None
    logger.warning("[Farmaa] DATABASE_URL not set. DB features disabled.")


class Base(DeclarativeBase):
    pass


def get_db():
    """FastAPI dependency – yields a database session."""
    if SessionLocal is None:
        raise Exception("Database not configured. Set DATABASE_URL environment variable.")
    
    db = SessionLocal()
    try:
        yield db
    except SQLAlchemyError as e:
        logger.error(f"[Farmaa] Database error: {e}")
        db.rollback()
        raise
    finally:
        db.close()


def create_tables():
    """Create all database tables."""
    if engine is not None:
        try:
            Base.metadata.create_all(bind=engine)
            logger.info("[Farmaa] Database tables created/verified ✓")
            return True
        except SQLAlchemyError as e:
            logger.error(f"[Farmaa] Failed to create tables: {e}")
            return False
    else:
        logger.warning("[Farmaa] Cannot create tables: No database engine available.")
        return False


def check_database_health():
    """Check if database is healthy and accessible."""
    if engine is None:
        return False, "Database engine not initialized"
    
    try:
        with engine.connect() as connection:
            result = connection.execute(text("SELECT 1"))
            return True, "Database connection healthy"
    except SQLAlchemyError as e:
        return False, f"Database connection failed: {str(e)}"
