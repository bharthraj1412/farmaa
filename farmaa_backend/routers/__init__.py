"""Routers package for Farmaa API.

This module exports all API routers for easy inclusion in the main application.
"""

from .auth_router import router as auth_router
from .crops_router import router as crops_router
from .orders_router import router as orders_router
from .ai_router import router as ai_router
from .market_router import router as market_router

__all__ = [
    "auth_router",
    "crops_router",
    "orders_router",
    "ai_router",
    "market_router",
]
