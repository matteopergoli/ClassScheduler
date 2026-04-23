# ClassScheduler

**AI-Powered Classroom Timetable Generator** for Android & iOS  
Flutter 3.22+ · Dart 3.4+ · SRS v2.1

---

## Quick Start

```bash
# 1. Run the setup script (handles everything below automatically)
chmod +x setup.sh && ./setup.sh
```

Or step by step:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
flutter run
```

---

## Project Structure

```
classscheduler/
├── lib/
│   ├── core/
│   │   ├── constants/      app_constants.dart  ← SA params, RC keys, Firestore paths
│   │   ├── router/         app_router.dart      ← go_router, 5-tab shell
│   │   └── theme/          app_colors.dart, app_text_styles.dart, app_theme.dart
│   ├── data/
│   │   ├── models/         app_models.dart      ← all Freezed entities
│   │   ├── repositories/   8 Firestore repositories
│   │   └── services/       auth_service.dart, subscription_service.dart
│   ├── domain/
│   │   ├── constraints/    conflict_detector, label_builder
│   │   ├── export/         pdf_export_service, excel_export_service, export_service
│   │   ├── scheduler/      phase1_greedy, phase2_sa, integrity_checker,
│   │   │                   scheduler_engine, scheduler_isolate, generation_service,
│   │   │                   drag_drop_validator
│   │   └── validation/     subject_validator
│   ├── l10n/               ARB files: EN (full) · IT (full) · ES/FR/DE (stubs)
│   ├── presentation/
│   │   ├── auth/           login, register, forgot_password
│   │   ├── constraints/    constraints_screen, constraint_form_screen
│   │   ├── schedule/       schedule_screen, schedule_grid, result_panel,
│   │   │                   version_sheet, export_sheet
│   │   ├── schools/        schools_screen, school_form_sheet
│   │   ├── settings/       settings_screen, subscription_screen
│   │   ├── setup/          setup_screen + 4 step screens
│   │   ├── shell/          main_shell.dart (bottom nav)
│   │   └── widgets/        CsButton, CsTextField, CsDropdown, QualityRing,
│   │                       TrialBanner, CsSocialButton
│   ├── providers/          theme_provider, locale_provider, selected_school_provider
│   ├── app.dart
│   └── main.dart
├── test/
│   ├── helpers/            scheduler_fixtures, engine_test_runner, fake_firebase
│   ├── unit/
│   │   ├── scheduler/      scheduling_engine_test.dart  (ALG-T01–15)
│   │   └── validation/     constraint_validator_test.dart
│   └── integration/        acceptance_test.dart  (AC-01–15)
├── tool/
│   └── sa_tuning.dart      SA parameter benchmark (§8.6.3)
├── assets/
│   ├── fonts/              ← place DM Sans + Playfair Display TTFs here
│   └── icons/              ← place google.svg + apple.svg here
├── firestore.rules
├── firestore.indexes.json
├── pubspec.yaml
├── l10n.yaml
├── setup.sh                ← run this first
└── QA_CHECKLIST.md
```

---

## Milestones

| # | Milestone | Status |
|---|-----------|--------|
| M1 | Scaffold & Auth | ✅ Complete |
| M2 | Setup Flows | ✅ Complete |
| M3 | Constraint Engine | ✅ Complete |
| M4 | Scheduling Algorithm (MCF Greedy + SA) | ✅ Complete |
| M5 | Schedule Viewer & Editor | ✅ Complete |
| M6 | Export & Monetisation | ✅ Complete |
| M7 | Test & Debug Procedure | ✅ Complete |

---

## Prerequisites

| Tool | Required version | Install |
|------|-----------------|---------|
| Flutter | ≥ 3.22 | https://flutter.dev/docs/get-started/install |
| Dart | ≥ 3.4 | bundled with Flutter |
| firebase-tools | latest | `npm install -g firebase-tools` |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` |

---

## Required Setup (before first run)

### 1 — Firebase

```bash
# Create project at https://console.firebase.google.com
# Then from this directory:
flutterfire configure --project=YOUR_PROJECT_ID --platforms=android,ios
```

This generates `lib/firebase_options.dart` and places the config files automatically.

**Enable in Firebase Console:**
- Authentication → Email/Password, Google, Apple
- Firestore → Create database (production mode)
- Deploy: `firebase deploy --only firestore:rules,firestore:indexes`

**Android only — SHA-1 fingerprint for Google Sign-In:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```
Add the SHA-1 in Firebase Console → Project Settings → Your Android app.

### 2 — RevenueCat (IAP)

1. Create project at https://app.revenuecat.com
2. Add Android + iOS apps
3. Create subscription product IDs:
   - Google Play: `classscheduler_annual_1490`  
   - App Store: nearest tier to €14.99/year
4. Create Entitlement: `classscheduler_annual`
5. Replace in `lib/core/constants/app_constants.dart`:
   ```dart
   static const String rcApiKeyAndroid = 'YOUR_RC_ANDROID_KEY';
   static const String rcApiKeyIos     = 'YOUR_RC_IOS_KEY';
   ```

### 3 — Fonts

Download and place in `assets/fonts/`:
- **DM Sans**: https://fonts.google.com/specimen/DM+Sans  
  → `DMSans-Regular.ttf`, `DMSans-Medium.ttf`, `DMSans-SemiBold.ttf`, `DMSans-Bold.ttf`
- **Playfair Display**: https://fonts.google.com/specimen/Playfair+Display  
  → `PlayfairDisplay-Bold.ttf`, `PlayfairDisplay-ExtraBold.ttf`

### 4 — Social Sign-In Icons

Place in `assets/icons/`:
- `google.svg` — from https://developers.google.com/identity/branding-guidelines
- `apple.svg` — white Apple logo from Apple HIG

### 5 — Platform files (android/ and ios/)

These are auto-generated by Flutter and **not included in the zip** (they contain machine-specific Gradle/Xcode configs). The setup script handles this:

```bash
./setup.sh   # generates android/ and ios/ automatically
```

Or manually:
```bash
flutter create --org com.classscheduler --project-name classscheduler \
  --platforms android,ios /tmp/cs_scaffold
cp -r /tmp/cs_scaffold/android ./
cp -r /tmp/cs_scaffold/ios ./
```

---

## Development Workflow

```bash
# Full rebuild after model changes
dart run build_runner build --delete-conflicting-outputs

# Localisation (after editing ARB files)
flutter gen-l10n

# Run all tests
flutter test

# Run SA tuning benchmark (before release)
dart run tool/sa_tuning.dart

# Firebase emulators (local dev — no real Firebase needed)
firebase emulators:start --only auth,firestore
```

---

## Running on Device / Emulator

```bash
flutter devices                        # list available devices
flutter run                            # pick first device
flutter run -d emulator-5554          # Android emulator by ID
flutter run -d "iPhone 15"            # iOS Simulator by name
flutter run --release                  # release mode (no debug banner)
```

---

## Building for Release

**Android App Bundle (Play Store):**
```bash
# Create keystore once:
keytool -genkey -v -keystore classscheduler-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias classscheduler

# Build:
flutter build appbundle --release
# → build/app/outputs/bundle/release/app-release.aab
```
Configure `android/key.properties` and `android/app/build.gradle` for signing.  
Guide: https://docs.flutter.dev/deployment/android

**iOS IPA (App Store):**
```bash
flutter build ios --release
# Then: Xcode → Product → Archive → Distribute App
```
Guide: https://docs.flutter.dev/deployment/ios

---

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.5.1 | State management |
| go_router | ^14.2.0 | Navigation |
| firebase_core | ^3.3.0 | Firebase |
| firebase_auth | ^5.1.4 | Authentication |
| cloud_firestore | ^5.2.1 | Database + offline cache |
| purchases_flutter | ^7.8.0 | RevenueCat IAP |
| freezed | ^2.5.7 | Immutable models |
| pdf | ^3.11.1 | PDF export |
| excel | ^4.0.3 | Excel export |
| share_plus | ^9.0.0 | OS share sheet |
| shared_preferences | ^2.3.1 | Offline subscription cache |

Full list in `pubspec.yaml`.

---

## Before Store Submission

See `QA_CHECKLIST.md` for the complete pre-submission checklist.

Key items:
- [ ] Replace RevenueCat placeholder keys
- [ ] Run `flutterfire configure`
- [ ] Add SHA-1 to Firebase (Android)
- [ ] Add font files
- [ ] Add icon SVGs
- [ ] Run `dart run tool/sa_tuning.dart` and update SA params if needed
- [ ] Run full test suite: `flutter test`
- [ ] Complete all items in QA_CHECKLIST.md

---

## Security

- All Firebase communication uses HTTPS/TLS
- Firestore Security Rules enforce per-user data isolation
- `trialUsed` stored in Firestore (not device storage) — survives reinstall
- RevenueCat status cached for 30 days offline (FR-SUB-IAP-03)
- Account deletion removes all Firestore data within 30 days (GDPR Art. 17)
