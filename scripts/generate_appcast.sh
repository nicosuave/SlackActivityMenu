#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -f "$ROOT/.release.env" ]]; then
  set -a
  source "$ROOT/.release.env"
  set +a
fi

APP_NAME="SlackActivityMenu"
VERSION="${APP_VERSION:-0.1.1}"
RELEASE_TAG="${RELEASE_TAG:-v$VERSION}"
SPARKLE_ACCOUNT="${SPARKLE_ACCOUNT:-com.nicholasritschel.SlackActivityMenu}"
DOWNLOAD_URL_PREFIX="${SPARKLE_DOWNLOAD_URL_PREFIX:-https://github.com/nicosuave/SlackActivityMenu/releases/download/$RELEASE_TAG/}"
DOWNLOAD_URL_PREFIX="${DOWNLOAD_URL_PREFIX%/}/"
DMG_PATH="$ROOT/.build/$APP_NAME.dmg"
APPCAST_DIR="$ROOT/.build/appcast"
VERSIONED_DMG="$APPCAST_DIR/$APP_NAME-$VERSION.dmg"
RELEASE_NOTES_PATH="$APPCAST_DIR/$APP_NAME-$VERSION.md"
APPCAST_PATH="$APPCAST_DIR/appcast.xml"
GENERATE_APPCAST="$ROOT/.build/artifacts/sparkle/Sparkle/bin/generate_appcast"

cd "$ROOT"

if [[ ! -f "$DMG_PATH" ]]; then
  echo "DMG not found at $DMG_PATH." >&2
  echo "Run scripts/notarize.sh first." >&2
  exit 1
fi

if [[ ! -x "$GENERATE_APPCAST" ]]; then
  echo "Sparkle generate_appcast tool not found at $GENERATE_APPCAST." >&2
  echo "Run swift build first." >&2
  exit 1
fi

rm -rf "$APPCAST_DIR"
mkdir -p "$APPCAST_DIR"
cp "$DMG_PATH" "$VERSIONED_DMG"

if [[ -n "${RELEASE_NOTES_FILE:-}" ]]; then
  cp "$RELEASE_NOTES_FILE" "$RELEASE_NOTES_PATH"
else
  cat > "$RELEASE_NOTES_PATH" <<'MARKDOWN'
Adds Sparkle-based automatic update checks and a manual Check for Updates menu item.
MARKDOWN
fi

"$GENERATE_APPCAST" \
  --account "$SPARKLE_ACCOUNT" \
  --download-url-prefix "$DOWNLOAD_URL_PREFIX" \
  --embed-release-notes \
  --maximum-versions 1 \
  -o "$APPCAST_PATH" \
  "$APPCAST_DIR" >/dev/null

echo "$APPCAST_PATH"
echo "$VERSIONED_DMG"
