#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="SlackActivityMenu"
APP_DIR="$ROOT/.build/$APP_NAME.app"
ZIP_PATH="$ROOT/.build/$APP_NAME.zip"
STAPLED_ZIP_PATH="$ROOT/.build/$APP_NAME.notarized.zip"
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool}"

cd "$ROOT"
"$ROOT/scripts/package_release.sh" >/dev/null

xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$APP_DIR"
xcrun stapler validate "$APP_DIR"
spctl --assess --type execute --verbose=4 "$APP_DIR"

rm -f "$STAPLED_ZIP_PATH"
ditto -c -k --keepParent "$APP_DIR" "$STAPLED_ZIP_PATH"

echo "$STAPLED_ZIP_PATH"
