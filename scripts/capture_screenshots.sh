#!/usr/bin/env bash
# README képernyőképek generálása iOS szimulátoron.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

DEVICE="${SCREENSHOT_DEVICE:-iPhone 16 Pro}"
OUT_DIR="$ROOT/docs/screenshots"

echo "→ Szimulátor: $DEVICE"
xcrun simctl boot "$DEVICE" 2>/dev/null || true
open -a Simulator

flutter pub get
mkdir -p "$OUT_DIR"

for screen in home meals workout; do
  echo "→ Képernyőkép: $screen"
  flutter test integration_test/screenshot_test.dart \
    -d "$DEVICE" \
    --dart-define="SCREENSHOT_SCREEN=$screen" \
    --reporter expanded

  src="build/integration_test/${screen}_*.png"
  # A takeScreenshot a build/integration_test/ mappába ment.
  found="$(compgen -G "$src" || true)"
  if [[ -z "$found" ]]; then
    # Régebbi Flutter: közvetlenül a build mappában
    found="$(find build -name "${screen}*.png" -type f 2>/dev/null | head -1 || true)"
  fi
  if [[ -n "$found" ]]; then
    cp "$found" "$OUT_DIR/$screen.png"
    echo "   Mentve: docs/screenshots/$screen.png"
  else
    echo "   Figyelem: nem található $screen képernyőkép a build/ alatt." >&2
  fi
done

echo "✓ Kész: $OUT_DIR"
