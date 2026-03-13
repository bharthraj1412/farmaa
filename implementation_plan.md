# Implementation Plan: Refactor OTP, Crops, and UI

## User Review Required

> [!WARNING]  
> The [auth_router.py](file:///g:/farmaa%20project/farmaa_backend/routers/auth_router.py) will transition from an in-memory dictionary (`_otp_store`) to a database table (`OtpCode`) for storing OTPs. This requires a database schema migration. I will use SQLAlchemy `Base.metadata.create_all` to automatically create the new table via a migration script.
> We also need to add a new dependency: `pytest` and `httpx` / `pytest-asyncio` for the backend tests if they don't exist, and `cached_network_image` for the Flutter frontend. 

## Proposed Changes

### Backend Changes

#### [NEW] `farmaa_backend/tests/test_auth.py`
- Add `test_send_otp_creates_record_and_respects_rate_limit`
- Add `test_verify_otp_returns_token_and_marks_used`

#### [NEW] `farmaa_backend/tests/test_crops.py`
- Add `test_crops_list_returns_all_roles`

#### [MODIFY] [farmaa_backend/models.py](file:///g:/farmaa%20project/farmaa_backend/models.py)
- Add new `OtpCode` table mapping with fields: [id](file:///g:/farmaa%20project/farmaa_backend/models.py#12-14), [phone](file:///g:/farmaa%20project/farmaa_backend/schemas.py#13-20), `code`, `used` (Boolean, default=False), `ip_address`, `created_at`, `expires_at`.

#### [MODIFY] [farmaa_backend/schemas.py](file:///g:/farmaa%20project/farmaa_backend/schemas.py)
- Update [UserUpdate](file:///g:/farmaa%20project/farmaa_backend/schemas.py#74-79) schema to allow updating [phone](file:///g:/farmaa%20project/farmaa_backend/schemas.py#13-20).
- Create a `CropListResponse` schema mimicking `{ "total": int, "items": List[CropOut] }`.

#### [MODIFY] [farmaa_backend/routers/auth_router.py](file:///g:/farmaa%20project/farmaa_backend/routers/auth_router.py)
- Change [send_otp](file:///g:/farmaa%20project/farmaa_backend/routers/auth_router.py#68-100): Persist the generated OTP in the `OtpCode` database table. Track rate-limiting using database queries counting attempts per [phone](file:///g:/farmaa%20project/farmaa_backend/schemas.py#13-20) and per `request.client.host` (IP Address) over the last minute.
- Change [verify_otp](file:///g:/farmaa%20project/farmaa_backend/routers/auth_router.py#102-181): Retrieve the OTP from the database. Mark `used = True` upon success. Only return an [access_token](file:///g:/farmaa%20project/farmaa_backend/auth.py#42-55) after this successful database verification.
- Change [update_profile](file:///g:/farmaa%20project/farmaa_backend/routers/auth_router.py#203-222) (`PATCH /auth/me`): Accept [phone](file:///g:/farmaa%20project/farmaa_backend/schemas.py#13-20) updates. If `body.phone` is provided and differs from the current phone, update it and immediately set `user.is_verified = False`.

#### [MODIFY] [farmaa_backend/routers/crops_router.py](file:///g:/farmaa%20project/farmaa_backend/routers/crops_router.py)
- Update the `GET /crops` endpoint to return the paginated `{ "total": <count>, "items": [...] }` format using `CropListResponse`. Verify there are no explicit role filters applied (the current code targets `is_available == True`, which is correct).

---

### Frontend (Flutter) Changes

#### [MODIFY] [farmaa_mobile/pubspec.yaml](file:///g:/farmaa%20project/farmaa_mobile/pubspec.yaml)
- Add `cached_network_image` dependency for robust image loading and caching.

#### [MODIFY] [farmaa_mobile/lib/core/services/crop_service.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/core/services/crop_service.dart)
- Adapt the fetch implementation to parse the new `{ total, items }` JSON structure instead of a direct array.

#### [MODIFY] [farmaa_mobile/lib/features/auth/screens/onboarding_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/auth/screens/onboarding_screen.dart)
- Overhaul the Bottom action area. Insert two massive, full-width CTAs (min height 56) for "LOGIN" (Primary filled) and "REGISTER" (Outline).

#### [MODIFY] [farmaa_mobile/lib/features/auth/screens/login_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/auth/screens/login_screen.dart)
- Decouple the native 2-step UI into a single step. The login screen will strictly capture the phone number, POST to `/auth/send-otp`, and then `context.push('/otp', extra: phone)` to navigate to dedicated OTP Screen.

#### [NEW] `farmaa_mobile/lib/features/auth/screens/otp_screen.dart`
- A dedicated OTP verification screen. POSTs phone+otp to `/auth/verify-otp`, writes the returned [access_token](file:///g:/farmaa%20project/farmaa_backend/auth.py#42-55) into `flutter_secure_storage`, and safely navigates to `/buyer/dashboard` (the unified marketplace).

#### [MODIFY] [farmaa_mobile/lib/features/shared/screens/profile_screen.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/shared/screens/profile_screen.dart)
- Embed an edit-phone modal or section. When the phone is changed, invoke the profile update endpoint, which sets `phone_verified=False` on the backend. Provide an option/button to trigger sending a new OTP to re-verify.

#### [MODIFY] [farmaa_mobile/lib/features/buyer/screens/buyer_dashboard.dart](file:///g:/farmaa%20project/farmaa_mobile/lib/features/buyer/screens/buyer_dashboard.dart)
- Wrap the main grid view in a `RefreshIndicator` for pull-to-refresh functionality. Use `CachedNetworkImage` instead of `Image.network` for robust crop imagery. Ensure the card styling has rounded corners and subtle shadows (`AppTheme.shadowSubtle`). Ensure seller metadata (which is mapped to `farmer_name` dynamically on the backend) is clearly rendered alongside price and quantity.

#### [NEW] `farmaa_mobile/integration_test/auth_e2e_test.dart`
- Write an E2E test to drive the input of a phone number, simulate tapping Login, hitting `/auth/send-otp`, entering the mock OTP `123456`, verifying via `/auth/verify-otp`, and asserting a redirect to the Marketplace displaying crop items.

---

### Final Deliverable Setup
- Write `git diff` patch and PR text details indicating assumptions.
- Add run script commands to the READMEs for fast developer startup and tests.

---

## Verification Plan

### Automated Tests
1.  **Backend PyTest**:
    -   `pytest tests/`  
    -   Run queries ensuring `OtpCode` respects limits, returns `429 Too Many Requests`, and correctly validates OTP limits/database entries. Guarantee [access_token](file:///g:/farmaa%20project/farmaa_backend/auth.py#42-55) isn't issued bypassing verification.
2.  **Frontend Flutter Test**:
    -   `flutter test integration_test/auth_e2e_test.dart`
    -   Verify the UI transition runs end-to-end to the Marketplace.

### Manual Verification
1.  Start backend (`uvicorn`) and inspect swagger at `http://localhost:8000/docs`. Observe the new crop pagination responses.
2.  Boot the mobile app. Asses Onboarding CTAs. Test the Login > OTP Screen flow. Watch the network logs for `send-otp` and `verify-otp`.
3.  Refresh the Marketplace screen by pulling down. Examine the rounded cards, shadows, and seller names on crops.
4.  Navigate to Profile. Update the phone number. Ensure the server reflects `is_verified: False`.
