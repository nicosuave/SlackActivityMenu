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
ZIP_PATH="$ROOT/.build/$APP_NAME.zip"
STAPLED_ZIP_PATH="$ROOT/.build/$APP_NAME.notarized.zip"
DMG_PATH="$ROOT/.build/$APP_NAME.dmg"
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool}"

cd "$ROOT"
"$ROOT/scripts/package_release.sh" >/dev/null

xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP_DIR"
xcrun stapler validate "$APP_DIR"
spctl --assess --type execute --verbose=4 "$APP_DIR"

rm -f "$STAPLED_ZIP_PATH"
ditto -c -k --keepParent "$APP_DIR" "$STAPLED_ZIP_PATH"

USE_EXISTING_APP=1 "$ROOT/scripts/package_dmg.sh" >/dev/null
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"
spctl --assess --type open --context context:primary-signature --verbose=4 "$DMG_PATH"
"$ROOT/scripts/generate_appcast.sh"

echo "$STAPLED_ZIP_PATH"
echo "$DMG_PATH"
