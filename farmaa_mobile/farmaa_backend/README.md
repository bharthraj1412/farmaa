# 🌾 Farmaa API

**Production REST API** for the Farmaa agricultural marketplace.  
Built with **FastAPI + PostgreSQL (Supabase)**, deployed on **Render**.

---

## 🚀 Live Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/` | ✗ | API info |
| `GET` | `/health` | ✗ | Health check |
| `GET` | `/docs` | ✗ | Swagger UI |
| `POST` | `/auth/send-otp` | ✗ | Send OTP to phone |
| `POST` | `/auth/verify-otp` | ✗ | Verify OTP → JWT token |
| `GET` | `/auth/me` | ✓ | Get user profile |
| `PATCH` | `/auth/me` | ✓ | Update profile |
| `POST` | `/auth/logout` | ✓ | Logout |
| `GET` | `/crops/` | ✗ | Browse all grains |
| `GET` | `/crops/my-listings` | ✓ | Farmer's own listings |
| `GET` | `/crops/{id}` | ✗ | Crop details |
| `POST` | `/crops/` | ✓ | Create crop listing |
| `PUT` | `/crops/{id}` | ✓ | Update crop |
| `DELETE` | `/crops/{id}` | ✓ | Delete crop |
| `POST` | `/orders/` | ✓ | Place order |
| `GET` | `/orders/my-orders` | ✓ | List orders |
| `GET` | `/orders/{id}` | ✓ | Order details |
| `PATCH` | `/orders/{id}/status` | ✓ | Update order status |

---

## 📦 Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | FastAPI |
| Database | PostgreSQL (Supabase) |
| ORM | SQLAlchemy 2.0 |
| Auth | JWT (python-jose) |
| Hosting | Render |

---

## ⚙️ Setup (Local Development)

```bash
# 1. Clone and enter backend
cd farmaa_backend

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate   # Linux/Mac
.\venv\Scripts\activate    # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Create .env from template
cp .env.example .env
# Edit .env with your DATABASE_URL and SECRET_KEY

# 5. Run server
uvicorn main:app --host 0.0.0.0 --port 10000 --reload
```

Open **http://localhost:10000/docs** for Swagger UI.

---

## 🔐 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `SECRET_KEY` | JWT signing secret | `your-random-secret-key` |
| `ENVIRONMENT` | Deployment environment | `production` |

---

## 🏗️ Project Structure

```
farmaa_backend/
├── main.py              # FastAPI app + CORS + health check
├── database.py          # SQLAlchemy engine + Supabase connection
├── models.py            # ORM models (User, Crop, Order, MarketPrice)
├── schemas.py           # Pydantic request/response schemas
├── auth.py              # JWT token creation + verification
├── requirements.txt     # Python dependencies (pinned versions)
├── render.yaml          # Render deployment config
├── Dockerfile           # Container deployment
├── .env.example         # Environment variables template
├── .gitignore
└── routers/
    ├── auth_router.py   # /auth/* – OTP login, profile
    ├── crops_router.py  # /crops/* – Grain marketplace CRUD
    └── orders_router.py # /orders/* – Order management
```

---

## 🌐 Deploy to Render

1. Push this repo to GitHub
2. Go to [render.com](https://render.com) → **New Web Service**
3. Connect your GitHub repo
4. Set:
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port 10000`
5. Add environment variables (`DATABASE_URL`, `SECRET_KEY`, `ENVIRONMENT`)
6. Deploy ✅

---

## 📊 Database Tables

| Table | Description |
|-------|-------------|
| `users` | Farmers, buyers, admins with phone-based auth |
| `crops` | Grain listings (8 categories: Rice, Wheat, Millet, Barley, Sorghum, Maize, Pulses, Other) |
| `orders` | Purchase orders with status tracking |
| `market_prices` | Live market price data |

---

## 📱 Mobile App

The Flutter mobile app connects to this API.  
See [`farmaa_mobile/`](../farmaa_mobile/) for the mobile app source code.

---

## 📞 Contact

**Farmaa** – From Farm to Future  
support@farmaa.in
