# 🌾 Farmaa API

**Production REST API** for the Farmaa agricultural marketplace.  
Built with **FastAPI + PostgreSQL (Supabase)**, deployed on **Vercel**.

---

## 🚀 Live Endpoints

**Base URL:** `https://farmaa-6zin.vercel.app`

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/` | ✗ | API info |
| `GET` | `/health` | ✗ | Health check |
| `GET` | `/docs` | ✗ | Swagger UI |
| **Auth** ||||
| `POST` | `/auth/send-otp` | ✗ | Send OTP to phone |
| `POST` | `/auth/verify-otp` | ✗ | Verify OTP → JWT token |
| `POST` | `/auth/google` | ✗ | Google Sign-In |
| `GET` | `/auth/me` | ✓ | Get user profile |
| `PATCH` | `/auth/me` | ✓ | Update profile |
| `POST` | `/auth/logout` | ✓ | Logout |
| **Crops** ||||
| `GET` | `/crops/` | ✗ | Browse all grains |
| `GET` | `/crops/my-listings` | ✓ | Farmer's own listings |
| `GET` | `/crops/{id}` | ✗ | Crop details |
| `POST` | `/crops/` | ✓ | Create crop listing |
| `PUT` | `/crops/{id}` | ✓ | Update crop |
| `DELETE` | `/crops/{id}` | ✓ | Delete crop |
| **Orders** ||||
| `POST` | `/orders/` | ✓ | Place order |
| `GET` | `/orders/my-orders` | ✓ | List orders |
| `GET` | `/orders/{id}` | ✓ | Order details |
| `PATCH` | `/orders/{id}/status` | ✓ | Update order status |
| **AI Advisor** ||||
| `POST` | `/ai/chat` | ✗ | Chat with AI advisor |
| **Market** ||||
| `GET` | `/market/prices` | ✗ | Live market prices |

---

## 📦 Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | FastAPI |
| Database | PostgreSQL (Supabase) |
| ORM | SQLAlchemy 2.0 |
| Auth | JWT (python-jose) |
| Hosting | Vercel (Serverless) |

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
| `DATABASE_URL` | Supabase PostgreSQL pooler URL | `postgresql://postgres.xxx:pass@aws-1-ap-south-1.pooler.supabase.com:6543/postgres` |
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
├── requirements.txt     # Python dependencies
├── vercel.json          # Vercel deployment config
├── .env.example         # Environment variables template
└── routers/
    ├── auth_router.py   # /auth/* – OTP login, Google auth, profile
    ├── crops_router.py  # /crops/* – Grain marketplace CRUD
    ├── orders_router.py # /orders/* – Order management + Razorpay
    ├── ai_router.py     # /ai/* – AI advisor chat
    └── market_router.py # /market/* – Live market prices
```

---

## 🌐 Deploy to Vercel

1. Push this repo to GitHub
2. Go to [vercel.com](https://vercel.com) → **New Project**
3. Import your GitHub repo
4. Set **Root Directory** to `farmaa_backend`
5. Add environment variables (`DATABASE_URL`, `SECRET_KEY`, `ENVIRONMENT`)
6. Deploy ✅ (auto-deploys on every push)

---

## 📊 Database Tables

| Table | Description |
|-------|-------------|
| `users` | Farmers, buyers, admins with phone/Google auth |
| `crops` | Grain listings (Rice, Wheat, Millet, Barley, Sorghum, Maize, Pulses, Other) |
| `orders` | Purchase orders with Razorpay payment tracking |
| `market_prices` | Live market price data from APMC markets |

---

## 📱 Mobile App

The Flutter mobile app connects to this API.  
See [`farmaa_mobile/`](../farmaa_mobile/) for the mobile app source code.

---

## 📞 Contact

**Farmaa** – From Farm to Future  
bharathraj1412p@gmail.com
