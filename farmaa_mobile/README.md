# 🌾 Farmaa Mobile

**From Farm to Future** — A digital marketplace connecting farmers with buyers for all grains.

---

## 📱 App Overview

| Feature | Description |
|---------|-------------|
| **Authentication** | Phone OTP + Google Sign-In with role selection (Farmer / Buyer / Admin) |
| **Farmer Module** | Grain listings across 8 categories, editable pricing, order management |
| **Buyer Module** | Browse marketplace, detailed crop view, cart system, Razorpay checkout |
| **AI Assistant** | Real-time AI chat for price queries, yield advice, and sustainability tips |
| **Market Prices** | Live APMC market price data for informed selling decisions |
| **Push Notifications** | Firebase Cloud Messaging for order alerts |
| **Admin Panel** | User verification, platform stats, dispute management |
| **Multi-Language** | English + Tamil with instant language switching |

---

## 🚀 Prerequisites

- [Flutter SDK ≥ 3.3](https://docs.flutter.dev/get-started/install/windows)
- [Android Studio](https://developer.android.com/studio) with emulator, **or** a physical Android device
- Java 17+ (bundled in Android Studio)
- Run `flutter doctor` and resolve any issues

---

## ⚙️ Configuration

### Backend URL

The app connects to the **Vercel cloud backend** by default:

```dart
// lib/core/constants/app_constants.dart
static const String prodUrl = 'https://farmaa-ivory.vercel.app';
```

Environment config is managed via the `.env` file:
```
BASE_URL=https://farmaa-ivory.vercel.app
SUPABASE_URL=https://qhllzkyklmvvvqkpzhbj.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Firebase
- `android/app/google-services.json` — included ✅
- Firebase Core + FCM initialized in `main.dart` ✅

### Razorpay
- Test API Key in `AppConstants.razorpayKey` ✅

---

## 🏃 Running the App

```powershell
cd farmaa_mobile

# Fetch dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run on connected device / emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on a specific device
flutter devices
flutter run -d <device_id>
```

---

## 🧪 Testing

```powershell
# Static analysis
flutter analyze

# Unit + Widget tests
flutter test

# Integration tests (on device/emulator)
flutter test integration_test/app_test.dart
```

---

## 🗂️ Project Structure

```
farmaa_mobile/
├── lib/
│   ├── core/
│   │   ├── api/           # Dio client + interceptors + circuit breaker
│   │   ├── config/        # Environment config (.env loading)
│   │   ├── constants/     # AppConstants (URLs, Razorpay, categories)
│   │   ├── models/        # User, Crop, Cart, Order data models
│   │   ├── providers/     # Riverpod providers (auth, cart, locale)
│   │   ├── router/        # GoRouter with role-based guards
│   │   ├── services/      # Crop, Auth, AI, Order, Notification services
│   │   ├── theme/         # AppTheme (colors, typography, shadows)
│   │   └── widgets/       # Reusable widgets (NetworkErrorWidget)
│   ├── features/
│   │   ├── auth/          # Splash, Onboarding, Login screens
│   │   ├── farmer/        # Dashboard, Crops, Market Prices, AI, Orders
│   │   ├── buyer/         # Dashboard, Crop Detail, Cart, Checkout, Orders
│   │   ├── shared/        # Profile, Notifications, Settings screens
│   │   ├── ai_chat/       # AI chat assistant screen
│   │   └── admin/         # Admin dashboard with tabs
│   ├── generated/         # Auto-generated localization files
│   ├── l10n/              # ARB translation files (English + Tamil)
│   └── main.dart          # App entry point
├── android/               # Android platform config
├── test/                  # Unit & widget tests
└── integration_test/      # Integration tests
```

---

## 🌾 Grain Categories

| Category | Emoji |
|----------|-------|
| Rice | 🌾 |
| Wheat | 🌿 |
| Millet | 🌻 |
| Barley | 🌰 |
| Sorghum | 🌱 |
| Maize | 🌽 |
| Pulses | 🫘 |
| Other | 🌾 |

---

## 🔑 Key Business Rules

| Rule | Details |
|------|---------|
| **Editable Pricing** | Farmers can update crop prices anytime |
| **Minimum Order** | Default 50 kg per order (configurable per crop) |
| **Role Routing** | Farmers → `/farmer/*`, Buyers → `/buyer/*`, Admin → `/admin` |
| **Cart System** | Buyers can add multiple items, adjust quantities, checkout |
| **OTP Login** | Demo OTP: `123456` (works in offline/demo mode) |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| UI | Flutter 3.x |
| State | Riverpod 2 |
| HTTP | Dio + interceptors |
| Navigation | go_router |
| Storage | flutter_secure_storage |
| Push | firebase_messaging |
| Charts | fl_chart |
| Payment | razorpay_flutter |
| i18n | flutter_localizations + ARB |
| Backend | FastAPI + Supabase PostgreSQL |
| Hosting | Vercel (Serverless) |

---

## 🌐 Architecture

```
┌─────────────────┐     HTTPS      ┌──────────────┐        ┌──────────────┐
│  Flutter Mobile  │ ──────────────▶│  Vercel API  │───────▶│   Supabase   │
│  (Android/iOS/   │◀────────────── │  (FastAPI)   │◀───────│  PostgreSQL  │
│   Web)           │                └──────────────┘        └──────────────┘
└─────────────────┘
```

---

## 📞 Contact

**Farmaa** – From Farm to Future  
bharathraj1412p@gmail.com
