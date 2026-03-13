import pytest
from models import User, Crop

def test_crops_list_returns_all_roles(client, setup_db):
    db = setup_db
    farmer_user = User(id="f1", phone="8888888888", name="Farmer 1", role="farmer")
    db.add(farmer_user)
    db.commit()
    
    crop1 = Crop(id="c1", farmer_id="f1", name="Wheat", price_per_kg=10.0, stock_kg=100)
    crop2 = Crop(id="c2", farmer_id="f1", name="Rice", price_per_kg=20.0, stock_kg=50)
    db.add_all([crop1, crop2])
    db.commit()
    db.close()
    
    response = client.get("/crops")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert data["total"] == 2
    assert len(data["items"]) == 2
    
    names = [c["name"] for c in data["items"]]
    assert "Wheat" in names
    assert "Rice" in names
