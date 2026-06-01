#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -f "$ROOT/.release.env" ]]; then
  set -a
  source "$ROOT/.release.env"
  set +a
fi

APP_NAME="SlackActivityMenu"
APP_DIR="$ROOT/.build/$APP_NAME.app"
DMG_ROOT="$ROOT/.build/$APP_NAME-dmg"
DMG_PATH="$ROOT/.build/$APP_NAME.dmg"
VOLUME_NAME="${DMG_VOLUME_NAME:-$APP_NAME}"

cd "$ROOT"

if [[ "${USE_EXISTING_APP:-0}" != "1" ]]; then
  "$ROOT/scripts/package_release.sh" >/dev/null
fi

if [[ ! -d "$APP_DIR" ]]; then
  echo "App bundle not found at $APP_DIR." >&2
  echo "Run scripts/package_release.sh first, or unset USE_EXISTING_APP." >&2
  exit 1
fi

IDENTITY="${CODESIGN_IDENTITY:-}"
if [[ -z "$IDENTITY" ]]; then
  IDENTITY="$(security find-identity -v -p codesigning | awk -F '"' '/Developer ID Application/ {print $2; exit}')"
fi

if [[ -z "$IDENTITY" ]]; then
  echo "No Developer ID Application signing identity found." >&2
  echo "Set CODESIGN_IDENTITY to sign the disk image." >&2
  exit 1
fi

rm -rf "$DMG_ROOT" "$DMG_PATH"
mkdir -p "$DMG_ROOT"
ditto "$APP_DIR" "$DMG_ROOT/$APP_NAME.app"
ln -s /Applications "$DMG_ROOT/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$DMG_ROOT" \
  -fs HFS+ \
  -format UDZO \
  -ov \
  "$DMG_PATH" >/dev/null

rm -rf "$DMG_ROOT"

codesign --force --timestamp --sign "$IDENTITY" "$DMG_PATH"
codesign --verify --verbose=2 "$DMG_PATH"
hdiutil verify "$DMG_PATH" >/dev/null

echo "$DMG_PATH"
