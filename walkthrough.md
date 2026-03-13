# 🌾 Farmaa Project Walkthrough

This document provides a comprehensive overview of the **Farmaa** ecosystem, which consists of a Python/FastAPI backend and a Dart/Flutter mobile application. It details the structural responsibilities and workings of every key file in the codebase.

---

## 1. High-Level Architecture

The project is structured into two main directories:
- `farmaa_backend/`: A robust REST API running on **FastAPI** connected to a **Supabase (PostgreSQL)** database.
- `farmaa_mobile/`: A modern **Flutter** mobile app integrating with Firebase (for push notifications/Google Auth) and Razorpay (payments). Both Farmers and Buyers share a single, unified app experience.

---

## 2. Backend Ecosystem (`farmaa_backend/`)

The backend is built around FastAPI and SQLAlchemy, utilizing an MVC-like structure for handling database operations, data validation, and routing.

### Core Configuration & Startup
- **[main.py](file:///g:/farmaa%20project/farmaa_backend/main.py)**: The entry point of the application. It initializes the FastAPI [app](file:///g:/farmaa%20project/farmaa_mobile/lib/features/shared/screens/main_shell.dart#29-48), sets up CORS (Cross-Origin Resource Sharing) for the Vercel app domains, applies global middleware (`SecurityHeadersMiddleware`, `RequestLoggingMiddleware`), implements route rate-limiting, handles database health checks on startup, and includes all the feature routers.
- **[database.py](file:///g:/farmaa%20project/farmaa_backend/database.py)**: Handles database connection logistics. It reads the `DATABASE_URL` from the environment, sets up the SQLAlchemy `create_engine` (with connection pooling), manages session lifecycles, and exposes [get_db()](file:///g:/farmaa%20project/farmaa_backend/database.py#64-78) which is used as a dependency across all API routes to run queries safely.
- **[models.py](file:///g:/farmaa%20project/farmaa_backend/models.py)**: Contains the SQLAlchemy Object-Relational Mapping (ORM) classes:
  - [User](file:///g:/farmaa%20project/farmaa_backend/models.py#16-33): Manages identity (farmers/buyers), phone, OTP state, verification, and role data.
  - [Crop](file:///g:/farmaa%20project/farmaa_backend/models.py#35-57): Represents physical crop listings (stock, price, farmer relationship).
  - [Order](file:///g:/farmaa%20project/farmaa_backend/models.py#59-79): Represents transactional data including Razorpay keys and buyer/farmer linkage.
  - [MarketPrice](file:///g:/farmaa%20project/farmaa_backend/models.py#81-91): Represents historical pricing trends for specific grains and districts.
- **[schemas.py](file:///g:/farmaa%20project/farmaa_backend/schemas.py)**: Contains the Pydantic models used to validate incoming JSON request bodies and serialize outgoing JSON responses. It ensures strong typing across endpoints.
- **[auth.py](file:///g:/farmaa%20project/farmaa_backend/auth.py)**: Contains core security logic. Generates JWT access tokens, hashes passwords (if used), checks OTP secrets, handles Google OAuth logic, and provides the `get_current_user` dependency used to protect authenticated routes.

### API Routers (`/routers`)
These files split the [main.py](file:///g:/farmaa%20project/farmaa_backend/main.py) logic into modular API endpoints:
- **`auth_router.py`**: Endpoints for sending OTPs, verifying OTPs, managing Google login callbacks, retrieving the current profile, and updating profile settings (like phone, village, and organization).
- **`crops_router.py`**: CRUD (Create, Read, Update, Delete) endpoints for [Crop](file:///g:/farmaa%20project/farmaa_backend/models.py#35-57) models. Allows users to list their produce or browse the marketplace catalogue.
- **`orders_router.py`**: Handles the e-commerce flow. Connects with Razorpay's API to initialize a transaction, stores the order under [Order](file:///g:/farmaa%20project/farmaa_backend/models.py#59-79) in the database, and verifies the Razorpay signature upon payment completion.
- **`ai_router.py`**: Endpoints related to the AI agricultural consultant features (like yield prediction simulation and sustainability scoring).
- **`market_router.py`**: Endpoints to fetch live or historical APMC market price data for grain comparison.

### Deployment & Tooling
- **[requirements.txt](file:///g:/farmaa%20project/farmaa_backend/requirements.txt) / [pyproject.toml](file:///g:/farmaa%20project/farmaa_backend/pyproject.toml)**: Package management files defining python dependencies (FastAPI, SQLAlchemy, psycopg2, razorpay).
- **[vercel.json](file:///g:/farmaa%20project/farmaa_backend/vercel.json) / [render.yaml](file:///g:/farmaa%20project/farmaa_backend/render.yaml)**: Serverless deployment configuration files describing how the code should be built and executed on Vercel/Render respectively.
- **[middleware.py](file:///g:/farmaa%20project/farmaa_backend/middleware.py)**: Custom request/response intercepters. It assigns unique Request IDs, forces strict security headers, and logs response times for monitoring.
- **`.env.*`**: Environment variable files holding the `DATABASE_URL`, `SECRET_KEY`, and context information.

---

## 3. Mobile Ecosystem (`farmaa_mobile/`)

The Flutter application relies on **Riverpod** for state management, **GoRouter** for navigation, and **Dio** for HTTP networking.

### Application Entry
- **`lib/main.dart`**: The Flutter entry point. It sets up Firebase/Google Services, initializes the local storage, configures language localization (English/Tamil), wraps the app in a `ProviderScope` (for Riverpod), and launches the `MaterialApp.router`.

### Core Layer (`lib/core/`)
This is the foundational code utilized across all features:
- **`api/api_client.dart`**: A configured `Dio` instance containing interceptors. It automatically injects the active user's JWT Authorization token into outbound requests and centralizes error handling logic.
- **`config/environment_config.dart`**: Loads the [.env](file:///g:/farmaa%20project/farmaa_mobile/.env) file to fetch secrets such as `BASE_URL` and `SUPABASE_ANON_KEY`.
- **`constants/app_constants.dart`**: A registry of static variables (e.g., grain categories, fixed routes, fallback URLs, UI padding sizes, theme constants).
- **`theme/app_theme.dart`**: Defines the central design language—vibrant greens, text styles, gradient styles, and custom button shapes.
- **`models/`**: Dart implementations of the backend Pydantic models (e.g., `user_model.dart`, `crop_model.dart`, `cart_item.dart`). They handle parsing JSON from the APIs into typed objects.
- **`providers/`**: Global state providers:
  - `auth_provider.dart`: Tracks the logged-in user state. Interacts with the `AuthService` to trigger logins and securely stores the JWT in `flutter_secure_storage`.
  - `cart_provider.dart`: Tracks locally added cart items before checkout.
- **`router/app_router.dart`**: The single source of truth for app navigation. It defines `/login`, `/home`, `/cart`, `/profile`, and establishes redirect logic (if not logged in → send to `/onboarding`).
- **`services/`**: The bridge to the backend (or 3rd-party services).
  - `auth_service.dart`, `crop_service.dart`: Map directly to `auth_router.py` and `crops_router.py`. They parse API responses into core models.
  - `notification_service.dart`: Integrates Firebase Cloud Messaging for order alerts.

### Feature Layers (`lib/features/`)
The UI is broken down by operational domains:

- **`auth/`**
  - `splash_screen.dart`: Logo loading screen, checks initial network and auth status.
  - `onboarding_screen.dart`: Educational carousel introducing the app functionalities.
  - [register_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/auth/screens/register_screen.dart) / [login_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/auth/screens/login_screen.dart): Forms for capturing Phone numbers to request OTPs via the `authProvider`, with alternative Google Sign-In support.

- **`shared/`** (Cross-role Unified UI)
  - [main_shell.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/shared/screens/main_shell.dart): A root `Scaffold` providing the Bottom Navigation Bar (Market, My Crops, Cart, Orders, Profile). Every user gets this shell.
  - [profile_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/shared/screens/profile_screen.dart): Fetches current user info, displays stats, provides settings, and triggers profile updates. Includes shortcuts to Market Prices and AI.
  - `orders_screen.dart`: A `TabBarView` displaying "Purchases" and "Sales" based on the user's role/history.

- **`buyer/`**
  - `crop_detail_screen.dart`: Deep dive into a specific crop providing descriptions, pricing, and an "Add to Cart" button.
  - `cart_screen.dart` / `checkout_screen.dart`: Reviews selected items and initiates the Razorpay `order_service.dart` bridge to secure payment.

- **`farmer/`**
  - `add_edit_crop_screen.dart`: Form to POST/PUT crop listings. Captures images and assigns grain categories.
  - `crop_list_screen.dart`: Overview of the farmer's current inventory.
  - [farmer_ai_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/farmer/screens/farmer_ai_screen.dart): Interacts with `ai_router.py` to calculate Sustainability Scores and predict yields based on environmental specs.
  - [market_prices_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/farmer/screens/market_prices_screen.dart): Fetches live APMC grain prices (`market_router.py`) and renders historical trend lines using `fl_chart`.

- **`ai_chat/`**
  - `ai_chat_screen.dart`: An interactive ChatGPT-style conversational UI to ask general agricultural queries. (This routes back to the backend `ai_router.py`).

### Localization & Generated Assets
- **`lib/l10n/`** (`app_en.arb`, `app_ta.arb`): JSON-style string mappings for translation dictionaries (English and Tamil).
- **`lib/generated/`**: Contains [.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/auth/screens/login_screen.dart) bindings created automatically by Flutter from the `.arb` files to allow strongly-typed translations (e.g., `AppLocalizations.of(context).login`).

---

## 4. Operational Data Flow (Example: Buying a Crop)
1. **App Initiation**: `main.dart` boots up. `app_router.dart` assesses `auth_provider.dart` for a saved JSON Web Token.
2. **Browsing**: The buyer lands on [main_shell.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/shared/screens/main_shell.dart) and views crops fetched by `crop_service.dart` making a `GET /crops` to FastAPI.
3. **Carting**: Buyer adds to cart. State updates in `cart_provider.dart`.
4. **Checkout**: Buyer hits checkout. Mobile calls `order_service.dart` (`POST /orders`). FastAPI validates data and connects to Razorpay to generate an Order ID.
5. **Payment**: The Razorpay mobile SDK takes over the UI. Upon success, Razorpay provides a signature to the app.
6. **Verification**: Mobile sends the signature back to FastAPI (`POST /orders/verify`). FastAPI verifies the signature against its secret key.
7. **Fulfillment**: If verified, FastAPI updates the DB ([models.py](file:///g:/farmaa%20project/farmaa_backend/models.py) -> `Order.status = 'paid'`), triggers a notification via Firebase, and returns a success payload to the app.

---

This architecture enforces separation of concerns, guarantees strict API type safety, and provides a polished, interactive mobile experience!
