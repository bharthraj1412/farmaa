# 🌾 Farmaa - Digitalizing Agriculture

**Farmaa** is a comprehensive solution designed to empower farmers and bridge the gap between rural production and urban consumption. It combines a powerful FastAPI backend with a modern Flutter mobile application to create a seamless marketplace ecosystem.

---

## 📂 Repository Structure

| Folder | Description | Tech Stack |
|--------|-------------|------------|
| **[`farmaa_backend/`](./farmaa_backend/)** | Production REST API | FastAPI, PostgreSQL (Supabase), SQLAlchemy |
| **[`farmaa_mobile/`](./farmaa_mobile/)** | Mobile Application | Flutter, Provider, Google Maps API |

---

## 🚀 Backend Deployment (Vercel/Render)

The backend is optimized for the **fastest deployment experience**:

### Vercel (Recommended)
1.  Connect your GitHub repo to **Vercel**.
2.  Set `farmaa_backend` as the **Root Directory**.
3.  Add Env Vars: `DATABASE_URL`, `SECRET_KEY`, `ENVIRONMENT`.
4.  Deploy! The `vercel.json` and `main.py` are already pre-configured.

### Render
1.  Create a new **Web Service**.
2.  Root Directory: `farmaa_backend`.
3.  Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`.

---

## 📱 Getting Started with Mobile

1.  Navigate to `farmaa_mobile/`.
2.  Run `flutter pub get`.
3.  Update the API base URL in `lib/core/config/env_config.dart`.
4.  Execute `flutter run`.

---

## ✨ Key Features
- **OTP & Google Auth**: Secure and easy onboarding for farmers.
- **AI Advisor**: Real-time agricultural consultancy.
- **Direct Marketplace**: Sell crops without middle-men.
- **Market Prices**: Live data from across markets to ensure fair pricing.

---

## 📞 Support
Created for the Farmaa Final Year Project.  
**Contact:** bharathraj1412p@gmail.com
[GitHub Repository](https://github.com/bharthraj1412/farmaa)
