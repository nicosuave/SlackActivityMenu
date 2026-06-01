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

cd "$ROOT"
"$ROOT/scripts/build_app.sh" >/dev/null

IDENTITY="${CODESIGN_IDENTITY:-}"
if [[ -z "$IDENTITY" ]]; then
  IDENTITY="$(security find-identity -v -p codesigning | awk -F '"' '/Developer ID Application/ {print $2; exit}')"
fi

if [[ -z "$IDENTITY" ]]; then
  echo "No Developer ID Application signing identity found." >&2
  echo "Set CODESIGN_IDENTITY to sign a release build." >&2
  exit 1
fi

codesign --force --timestamp --options runtime --sign "$IDENTITY" "$APP_DIR"
codesign --verify --strict --verbose=2 "$APP_DIR"

rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"

echo "$ZIP_PATH"
