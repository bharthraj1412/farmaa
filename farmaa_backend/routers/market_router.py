"""Market Prices router – Browse current market rates with demo data."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timedelta, timezone
import random
import uuid

from database import get_db
from models import MarketPrice
from schemas import MarketPriceOut
from middleware import sanitize_search_query

router = APIRouter(prefix="/market", tags=["Market Prices"])

# ── Demo market price data ───────────────────────────────────────────────────

DEMO_PRICES = [
    {"crop_name": "Rice (Sona Masoori)", "category": "Rice", "market_name": "Koyambedu, Chennai", "base_price": 35.0},
    {"crop_name": "Rice (Ponni)", "category": "Rice", "market_name": "Thanjavur Mandi", "base_price": 32.0},
    {"crop_name": "Rice (Basmati)", "category": "Rice", "market_name": "Delhi Wholesale", "base_price": 55.0},
    {"crop_name": "Wheat (HD-2967)", "category": "Wheat", "market_name": "Indore Mandi", "base_price": 26.0},
    {"crop_name": "Wheat (Lokwan)", "category": "Wheat", "market_name": "Pune APMC", "base_price": 28.0},
    {"crop_name": "Ragi (Finger Millet)", "category": "Millet", "market_name": "Mysuru Market", "base_price": 32.0},
    {"crop_name": "Bajra (Pearl Millet)", "category": "Millet", "market_name": "Jodhpur Mandi", "base_price": 24.0},
    {"crop_name": "Jowar (Sorghum)", "category": "Sorghum", "market_name": "Solapur APMC", "base_price": 28.0},
    {"crop_name": "Maize (Yellow)", "category": "Maize", "market_name": "Davangere Market", "base_price": 20.0},
    {"crop_name": "Maize (White)", "category": "Maize", "market_name": "Karnataka Mandi", "base_price": 18.0},
    {"crop_name": "Toor Dal", "category": "Pulses", "market_name": "Latur APMC", "base_price": 85.0},
    {"crop_name": "Chana Dal", "category": "Pulses", "market_name": "Rajkot Mandi", "base_price": 62.0},
    {"crop_name": "Moong Dal", "category": "Pulses", "market_name": "Indore APMC", "base_price": 78.0},
    {"crop_name": "Urad Dal", "category": "Pulses", "market_name": "Nagpur Mandi", "base_price": 72.0},
    {"crop_name": "Barley (Feed Grade)", "category": "Barley", "market_name": "Jaipur Mandi", "base_price": 22.0},
    {"crop_name": "Foxtail Millet (Thinai)", "category": "Millet", "market_name": "Salem Market", "base_price": 45.0},
    {"crop_name": "Barnyard Millet (Kuthiraivali)", "category": "Millet", "market_name": "Coimbatore APMC", "base_price": 42.0},
    {"crop_name": "Little Millet (Samai)", "category": "Millet", "market_name": "Erode Market", "base_price": 48.0},
]


@router.get("/prices", response_model=List[MarketPriceOut])
def list_market_prices(
    commodity: Optional[str] = Query(None),
    district: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """
    Fetch market prices filtered by commodity or district.
    Falls back to demo data if database has no entries.
    """
    query = db.query(MarketPrice)

    if commodity:
        safe_commodity = sanitize_search_query(commodity)
        query = query.filter(MarketPrice.crop_name.ilike(f"%{safe_commodity}%"))
    if district:
        safe_district = sanitize_search_query(district)
        query = query.filter(MarketPrice.market_name.ilike(f"%{safe_district}%"))

    results = query.order_by(MarketPrice.recorded_at.desc()).limit(50).all()

    # If no results from DB, return demo data
    if not results:
        return _generate_demo_prices(commodity, district)

    return results


@router.get("/prices/trends")
def get_price_trends(
    crop_name: str = Query(..., min_length=1),
    days: int = Query(30, ge=7, le=90),
    db: Session = Depends(get_db)
):
    """
    Get price trend data for a specific crop over the last N days.
    Returns daily average prices for charting.
    """
    safe_name = sanitize_search_query(crop_name)

    # Try to get real data
    from sqlalchemy import func
    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    results = db.query(
        func.date(MarketPrice.recorded_at).label("date"),
        func.avg(MarketPrice.price_per_kg).label("avg_price"),
        func.min(MarketPrice.price_per_kg).label("min_price"),
        func.max(MarketPrice.price_per_kg).label("max_price"),
    ).filter(
        MarketPrice.crop_name.ilike(f"%{safe_name}%"),
        MarketPrice.recorded_at >= cutoff,
    ).group_by(
        func.date(MarketPrice.recorded_at)
    ).order_by(
        func.date(MarketPrice.recorded_at)
    ).all()

    if results:
        return {
            "crop_name": crop_name,
            "period_days": days,
            "data": [
                {
                    "date": str(r.date),
                    "avg_price": round(float(r.avg_price), 2),
                    "min_price": round(float(r.min_price), 2),
                    "max_price": round(float(r.max_price), 2),
                }
                for r in results
            ],
        }

    # Return demo trend data
    return _generate_demo_trends(crop_name, days)


@router.post("/prices/seed")
def seed_market_prices(db: Session = Depends(get_db)):
    """Seed demo market prices into the database for testing."""
    count = 0
    for item in DEMO_PRICES:
        # Add multiple entries with slight price variations
        for i in range(5):
            variation = random.uniform(-0.1, 0.1)
            price = round(item["base_price"] * (1 + variation), 2)
            entry = MarketPrice(
                id=str(uuid.uuid4()),
                crop_name=item["crop_name"],
                category=item["category"],
                price_per_kg=price,
                market_name=item["market_name"],
                source="demo_seed",
                recorded_at=datetime.now(timezone.utc) - timedelta(days=random.randint(0, 30)),
            )
            db.add(entry)
            count += 1

    db.commit()
    return {"message": f"Seeded {count} market price entries", "status": "ok"}


# ── Helper Functions ─────────────────────────────────────────────────────────

def _generate_demo_prices(commodity: Optional[str], district: Optional[str]) -> list:
    """Generate demo price data when DB is empty."""
    prices = []
    for item in DEMO_PRICES:
        if commodity and commodity.lower() not in item["crop_name"].lower():
            continue
        if district and district.lower() not in item["market_name"].lower():
            continue

        variation = random.uniform(-0.08, 0.08)
        price = round(item["base_price"] * (1 + variation), 2)

        prices.append(MarketPriceOut(
            id=str(uuid.uuid4()),
            crop_name=item["crop_name"],
            category=item["category"],
            price_per_kg=price,
            market_name=item["market_name"],
            source="demo",
            recorded_at=datetime.now(timezone.utc),
        ))

    return prices


def _generate_demo_trends(crop_name: str, days: int) -> dict:
    """Generate demo trend data for charting."""
    base_price = 30.0
    for item in DEMO_PRICES:
        if crop_name.lower() in item["crop_name"].lower():
            base_price = item["base_price"]
            break

    data = []
    for i in range(days):
        date = datetime.now(timezone.utc) - timedelta(days=days - i)
        variation = random.uniform(-0.05, 0.05)
        # Add a slight upward trend
        trend = 1 + (i / days) * 0.03
        price = round(base_price * trend * (1 + variation), 2)
        data.append({
            "date": date.strftime("%Y-%m-%d"),
            "avg_price": price,
            "min_price": round(price * 0.95, 2),
            "max_price": round(price * 1.05, 2),
        })

    return {
        "crop_name": crop_name,
        "period_days": days,
        "data": data,
        "source": "demo",
    }
