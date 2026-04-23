#!/usr/bin/env bash
# =============================================================================
# ClassScheduler — First-Time Setup Script
# =============================================================================
# Run once after cloning/unzipping the project:
#   chmod +x setup.sh && ./setup.sh
#
# Requirements: Flutter 3.22+, Dart 3.4+, git, firebase-tools, FlutterFire CLI
# =============================================================================

set -e
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
fail() { echo -e "${RED}  ✗ $1${NC}"; exit 1; }
info() { echo -e "${BOLD}$1${NC}"; }

echo ""
echo "=============================================="
echo "  ClassScheduler Setup"
echo "=============================================="
echo ""

# ── 1. Check Flutter version ─────────────────────────────────────────────────
info "Step 1 — Checking Flutter"
if ! command -v flutter &>/dev/null; then
  fail "Flutter not found. Install from https://flutter.dev/docs/get-started/install"
fi
FLUTTER_VER=$(flutter --version 2>&1 | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
MIN="3.22.0"
if [ "$(printf '%s\n' "$MIN" "$FLUTTER_VER" | sort -V | head -1)" != "$MIN" ]; then
  fail "Flutter $FLUTTER_VER is too old. Need $MIN+. Run: flutter upgrade"
fi
ok "Flutter $FLUTTER_VER"

# ── 2. flutter create to generate android/ and ios/ ──────────────────────────
info ""
info "Step 2 — Generating Android & iOS platform files"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$SCRIPT_DIR/android" ] || [ ! -d "$SCRIPT_DIR/ios" ]; then
  warn "android/ and ios/ not found — running flutter create to generate them"
  warn "(This is normal; platform files cannot be hand-written)"
  
  # Create in a temp dir to avoid overwriting lib/
  TMPDIR=$(mktemp -d)
  flutter create \
    --org com.classscheduler \
    --project-name classscheduler \
    --platforms android,ios \
    --no-pub \
    "$TMPDIR/classscheduler" 2>&1 | grep -v "^$" | tail -20

  # Copy only the platform directories into our project
  cp -r "$TMPDIR/classscheduler/android" "$SCRIPT_DIR/"
  cp -r "$TMPDIR/classscheduler/ios"     "$SCRIPT_DIR/"
  rm -rf "$TMPDIR"
  ok "android/ and ios/ created"
else
  ok "android/ and ios/ already exist"
fi

# ── 3. Install dependencies ───────────────────────────────────────────────────
info ""
info "Step 3 — Installing dependencies"
flutter pub get
ok "Dependencies installed"

# ── 4. Code generation (Freezed + json_serializable + Riverpod) ──────────────
info ""
info "Step 4 — Running code generation (Freezed / Riverpod)"
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -5
ok "Code generation complete"

# ── 5. Localisation ───────────────────────────────────────────────────────────
info ""
info "Step 5 — Generating localisation files"
flutter gen-l10n 2>&1 | tail -5
ok "Localisation generated (lib/l10n/generated/)"

# ── 6. Firebase ───────────────────────────────────────────────────────────────
info ""
info "Step 6 — Firebase setup"
if [ -f "$SCRIPT_DIR/lib/firebase_options.dart" ]; then
  ok "firebase_options.dart already exists — skipping"
else
  warn "firebase_options.dart not found."
  echo ""
  echo "  You need to run FlutterFire CLI to connect to your Firebase project."
  echo "  If you haven't already:"
  echo ""
  echo "    1. Create a Firebase project at https://console.firebase.google.com"
  echo "    2. Install FlutterFire CLI:"
  echo "         dart pub global activate flutterfire_cli"
  echo "    3. From this directory, run:"
  echo "         flutterfire configure --project=YOUR_PROJECT_ID"
  echo ""
  echo "  This generates lib/firebase_options.dart and places"
  echo "  google-services.json / GoogleService-Info.plist automatically."
  echo ""
  echo "  Also enable in Firebase Console:"
  echo "    → Authentication: Email/Password, Google, Apple"
  echo "    → Firestore: create database (production mode)"
  echo "    → Deploy rules: firebase deploy --only firestore:rules,firestore:indexes"
  echo ""
  warn "Continuing without Firebase — app will not run until this is done"
fi

# ── 7. RevenueCat API keys ────────────────────────────────────────────────────
info ""
info "Step 7 — RevenueCat API keys"
CONSTANTS="$SCRIPT_DIR/lib/core/constants/app_constants.dart"
if grep -q "REVENUECAT_API_KEY_ANDROID" "$CONSTANTS"; then
  warn "RevenueCat keys are still placeholders in app_constants.dart"
  echo ""
  echo "  Replace in lib/core/constants/app_constants.dart:"
  echo "    rcApiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY'"
  echo "    rcApiKeyIos     = 'YOUR_REVENUECAT_IOS_KEY'"
  echo ""
  echo "  Get your keys from: https://app.revenuecat.com → Project → API Keys"
  echo ""
  warn "App will build but IAP will not work until keys are replaced"
else
  ok "RevenueCat keys are set"
fi

# ── 8. Fonts check ───────────────────────────────────────────────────────────
info ""
info "Step 8 — Font files"
FONTS_OK=true
for font in "DMSans-Regular.ttf" "DMSans-Bold.ttf" "PlayfairDisplay-Bold.ttf"; do
  if [ ! -f "$SCRIPT_DIR/assets/fonts/$font" ]; then
    FONTS_OK=false
    break
  fi
done

if $FONTS_OK; then
  ok "Font files present"
else
  warn "Font files missing in assets/fonts/"
  echo "  Download DM Sans: https://fonts.google.com/specimen/DM+Sans"
  echo "  Download Playfair Display: https://fonts.google.com/specimen/Playfair+Display"
  echo "  See assets/fonts/README.txt for exact filenames needed"
  echo ""
  warn "App will run but text will use system fallback fonts"
fi

# ── 9. Quick validation build (no device required) ───────────────────────────
info ""
info "Step 9 — Compile check"
flutter build web --no-pub 2>&1 | tail -5 || \
  flutter analyze --no-pub 2>&1 | grep -E "error|warning|hint" | head -20 || true
ok "Compile check done — see output above for any errors"

# ── 10. Run tests ─────────────────────────────────────────────────────────────
info ""
info "Step 10 — Running unit tests"
flutter test test/unit/ test/integration/ --no-pub 2>&1 | tail -15
echo ""

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "=============================================="
echo -e "${GREEN}${BOLD}  Setup complete!${NC}"
echo "=============================================="
echo ""
echo "  Next steps:"
echo "  1. Complete Firebase setup (Step 6 above) if not done"
echo "  2. Replace RevenueCat keys if not done"
echo "  3. Add font files if not done"
echo ""
echo "  To run the app:"
echo "    flutter run                          # picks first connected device"
echo "    flutter run -d emulator-5554        # Android emulator"
echo "    flutter run -d 'iPhone 15'          # iOS Simulator"
echo ""
echo "  To run tests:"
echo "    flutter test                         # all tests"
echo "    flutter test test/unit/              # unit tests only"
echo "    dart run tool/sa_tuning.dart         # SA benchmark"
echo ""
