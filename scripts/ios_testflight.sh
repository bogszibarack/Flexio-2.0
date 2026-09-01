#!/usr/bin/env bash
# TestFlight feltöltés — Apple Developer Program ($99/év) szükséges.
#
# Előfeltételek:
#   1. Xcode → Settings → Accounts → Apple ID bejelentkezés
#   2. developer.apple.com → App Store Connect → új app (bundle: com.kokaiadam.flexio)
#   3. Környezeti változók (ne commitold a kulcsokat!):
#        export SUPABASE_URL="https://<ref>.supabase.co"
#        export SUPABASE_PUBLISHABLE_KEY="sb_publishable_..."
#        export API_BASE_URL="https://flexio-api.onrender.com"
#        export APPLE_TEAM_ID="XXXXXXXXXX"   # Xcode → Signing & Capabilities
#
# Használat:
#   chmod +x scripts/ios_testflight.sh
#   ./scripts/ios_testflight.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

: "${SUPABASE_URL:?Állítsd be: export SUPABASE_URL=...}"
: "${SUPABASE_PUBLISHABLE_KEY:?Állítsd be: export SUPABASE_PUBLISHABLE_KEY=...}"

API_URL="${API_BASE_URL:-https://flexio-api.onrender.com}"
VERSION="$(grep '^version:' pubspec.yaml | awk '{print $2}')"
BUILD_NAME="${VERSION%%+*}"
BUILD_NUMBER="${VERSION#*+}"

echo "→ Flexio IPA build (v$BUILD_NAME+$BUILD_NUMBER)"

DART_DEFINES=(
  "--dart-define=SUPABASE_URL=$SUPABASE_URL"
  "--dart-define=SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY"
  "--dart-define=API_BASE_URL=$API_URL"
)

if [[ -n "${APPLE_TEAM_ID:-}" ]]; then
  echo "→ Team ID: $APPLE_TEAM_ID (állítsd be Xcode-ban is: Runner → Signing)"
fi

flutter pub get
flutter build ipa --release "${DART_DEFINES[@]}"

IPA_PATH="build/ios/ipa/fitness.ipa"
if [[ ! -f "$IPA_PATH" ]]; then
  IPA_PATH="$(find build/ios/ipa -name '*.ipa' | head -1)"
fi

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
  echo "Hiba: IPA nem készült el. Nyisd meg ios/Runner.xcworkspace Xcode-ban," >&2
  echo "állítsd be a Signing Team-et, majd próbáld újra." >&2
  exit 1
fi

echo "→ IPA: $IPA_PATH"
echo ""
echo "Feltöltés App Store Connectbe (Transporter vagy Xcode Organizer):"
echo "  open -a Transporter"
echo "  # vagy: xcrun altool --upload-app -f \"$IPA_PATH\" -t ios -u <apple-id>"
echo ""
echo "TestFlight lépések utána:"
echo "  1. appstoreconnect.apple.com → Apps → Flexio → TestFlight"
echo "  2. Várj a „Processing” befejezésére (~5–15 perc)"
echo "  3. Internal Testing → add hozzá magad"
echo "  4. External Testing → Beta App Review (első alkalommal) → Public Link"
echo ""
echo "A nyilvános TestFlight linket másold be a README „TestFlight” szekciójába."
