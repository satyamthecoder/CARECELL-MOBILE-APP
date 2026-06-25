# CareCell Frontend

Flutter 3.19+ · Riverpod · GoRouter · Dio

Cross-platform mobile app (Android + iOS) implementing both the Patient flow
and the Donor flow from the PRD.

## Quick Start

```bash
cd frontend
flutter pub get
```

Before running, point the app at your backend:

Edit `lib/core/constants/app_constants.dart`:
```dart
class AppEndpoints {
  static const baseUrl = 'https://api.carecell.in'; // ← change to your backend URL
  // for local backend testing on a real device, use your machine's LAN IP, e.g.
  // static const baseUrl = 'http://192.168.1.5:8080';
  // for Android emulator talking to a backend on your host machine, use:
  // static const baseUrl = 'http://10.0.2.2:8080';
}
```

Then run:
```bash
flutter run
```

## Project Layout

```
lib/
├── core/
│   ├── constants/      Colors, theme, endpoints, dimensions
│   ├── network/        Dio client with JWT interceptor + auto-refresh
│   └── router/         GoRouter config with auth guard
├── features/
│   ├── auth/            Splash, Welcome, Register, OTP, Login, Forgot Password
│   ├── patient/          Dashboard + 9 feature screens (health card, blood request,
│   │                     records, treatments, SOS, hospitals, schemes, AI chat, profile)
│   ├── donor/            Dashboard + 5 feature screens (profile/card, matches,
│   │                     records, eligibility)
│   └── shared/           Health card widget, bottom nav, feature grid item
└── main.dart
```

## What's Wired vs. What Needs Your Keys

| Feature | Status |
|---|---|
| Register / Login / OTP / JWT refresh | ✅ Fully wired to backend |
| Patient dashboard, blood requests, treatments, records list | ✅ Fully wired |
| Donor dashboard, profile, match requests, eligibility | ✅ Fully wired |
| Digital Health Card / Donor Card with QR | ✅ Fully wired |
| SOS (geolocation + alert trigger) | ✅ Fully wired — needs location permission granted at runtime |
| Hospital Finder | ✅ Wired — **requires `GOOGLE_MAPS_API_KEY` set on the backend**, and an Android/iOS Maps key in the native manifests |
| Scheme Finder | ✅ Wired (currently returns static seed data from backend — see backend README) |
| CareCell AI Chat | ✅ Wired to backend → FastAPI; FastAPI currently returns rule-based replies — wire in a real LLM (see `ai-service/app/main.py`) |
| File upload (health records) | ⚠️ Upload sheet UI is in place; the actual `multipart/form-data` POST call needs `file_picker` / `image_picker` wiring — see TODO in `health_records_screen.dart` and `donor_records_screen.dart` |
| Push notifications (FCM) | ⚠️ Dependency included, `Firebase.initializeApp()` commented out in `main.dart` — needs `google-services.json` / `GoogleService-Info.plist` |
| WhatsApp Assistant button | ⚠️ UI placeholder only — needs `url_launcher` wired to your WhatsApp Business number once provisioned |

## Building for Release

### Android
```bash
flutter build apk --release
# or for Play Store:
flutter build appbundle --release
```
Before this works you must:
1. Add `android/app/google-services.json` (from Firebase Console)
2. Replace the Maps API key placeholder in `android/app/src/main/AndroidManifest.xml`
3. Configure a real release keystore in `android/app/build.gradle` (currently
   signs release builds with the debug key — fine for testing, **not** for Play Store)

### iOS
```bash
flutter build ios --release
```
Before this works you must:
1. Add `ios/Runner/GoogleService-Info.plist` (from Firebase Console)
2. Set your Apple Developer Team in Xcode signing settings
3. Add a Google Maps API key to `ios/Runner/AppDelegate.swift` (not yet created — see root requirements checklist)

## Running Tests

```bash
flutter test
```

(Test files are not included in this scaffold — add widget/unit tests under
`test/` following standard Flutter conventions before production launch.)
