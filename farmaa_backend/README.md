# 🌾 Farmaa - From Farm to Future

**Farmaa** is a modern agricultural marketplace platform designed to bridge the gap between farmers and buyers. This repository contains the complete ecosystem, including the FastAPI backend and the Flutter mobile application.

---

## 🏗️ Project Overview

The project is divided into two main components:

1.  **[Backend (`farmaa_backend/`)](./farmaa_backend/)**: A production-ready REST API built with FastAPI, connected to Supabase (PostgreSQL).
2.  **[Mobile App (`farmaa_mobile/`)](./farmaa_mobile/)**: A feature-rich Flutter application for farmers and buyers.

---

## 🚀 Backend (FastAPI)

### Live Endpoints
- **Base URL:** `https://farmaa-ivory.vercel.app`
- **Swagger UI:** `https://farmaa-ivory.vercel.app/docs`

### Key Features
- **Authentication**: Phone-based OTP and Google Sign-In.
- **Marketplace**: Create, browse, and manage crop listings (Rice, Wheat, pulses, etc.).
- **Orders**: Secure order placement with Razorpay integration.
- **AI Advisor**: Real-time chat with an AI agricultural consultant.
- **Market Data**: Live grain prices from APMC markets.

### Easy Deployment (Vercel)
The backend is optimized for Vercel. To deploy:
1.  Import the `farmaa_backend` folder as the **Root Directory** in Vercel.
2.  Ensure `vercel.json` is present.
3.  Set the following **Environment Variables**:
    - `DATABASE_URL`: Your Supabase connection string.
    - `SECRET_KEY`: Your JWT encryption secret.
    - `ENVIRONMENT`: Set to `production`.
4.  Vercel will automatically detect `main.py` and deploy using `@vercel/python`.

---

## 📱 Mobile App (Flutter)

The Farmaa mobile app provides a seamless interface for farmers to list their produce and for buyers to discover fresh grains directly from the source.

### Setup
1.  Navigate to `farmaa_mobile/`.
2.  Run `flutter pub get` to install dependencies.
3.  Configure `lib/core/config/env_config.dart` with your API base URL.
4.  Run `flutter run`.

---

## ⚙️ Development Setup

```bash
# Backend Setup
cd farmaa_backend
python -m venv venv
.\venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn main:app --reload
```

---

## 📞 Contact & Support

**Farmaa Team**
- Email: bharathraj1412p@gmail.com
- Repository: [https://github.com/bharthraj1412/farmaa](https://github.com/bharthraj1412/farmaa)

