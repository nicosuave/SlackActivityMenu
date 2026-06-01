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
ICONSET_DIR="$ROOT/.build/$APP_NAME.iconset"
ICON_FILE="$ROOT/.build/$APP_NAME.icns"
VERSION="${APP_VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
SPARKLE_FEED_URL="${SPARKLE_FEED_URL:-https://github.com/nicosuave/SlackActivityMenu/releases/latest/download/appcast.xml}"
SPARKLE_PUBLIC_ED_KEY="${SPARKLE_PUBLIC_ED_KEY:-dazB6SspHM+NKOZQzsp4Qjd35Nm531lSYHTxTMLL2sg=}"

cd "$ROOT"
swift build -c release
BIN_DIR="$(swift build -c release --show-bin-path)"
EXECUTABLE="$BIN_DIR/$APP_NAME"
SPARKLE_FRAMEWORK="$BIN_DIR/Sparkle.framework"

if [[ ! -d "$SPARKLE_FRAMEWORK" ]]; then
  echo "Sparkle.framework not found at $SPARKLE_FRAMEWORK." >&2
  exit 1
fi

rm -rf "$ICONSET_DIR" "$ICON_FILE"
swift "$ROOT/scripts/generate_app_icon.swift" "$ICONSET_DIR"
iconutil -c icns "$ICONSET_DIR" -o "$ICON_FILE"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources" "$APP_DIR/Contents/Frameworks"
cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$APP_NAME"
install_name_tool -add_rpath "@executable_path/../Frameworks" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ICON_FILE" "$APP_DIR/Contents/Resources/$APP_NAME.icns"
ditto "$SPARKLE_FRAMEWORK" "$APP_DIR/Contents/Frameworks/Sparkle.framework"
rm -rf \
  "$APP_DIR/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices" \
  "$APP_DIR/Contents/Frameworks/Sparkle.framework/XPCServices"

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>SlackActivityMenu</string>
  <key>CFBundleIdentifier</key>
  <string>com.nicholasritschel.SlackActivityMenu</string>
  <key>CFBundleName</key>
  <string>SlackActivityMenu</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleIconFile</key>
  <string>SlackActivityMenu.icns</string>
  <key>CFBundleShortVersionString</key>
  <string>__VERSION__</string>
  <key>CFBundleVersion</key>
  <string>__BUILD_NUMBER__</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>SUEnableAutomaticChecks</key>
  <true/>
  <key>SUFeedURL</key>
  <string>__SPARKLE_FEED_URL__</string>
  <key>SUPublicEDKey</key>
  <string>__SPARKLE_PUBLIC_ED_KEY__</string>
</dict>
</plist>
PLIST

/usr/bin/sed -i '' \
  -e "s|__VERSION__|$VERSION|g" \
  -e "s|__BUILD_NUMBER__|$BUILD_NUMBER|g" \
  -e "s|__SPARKLE_FEED_URL__|$SPARKLE_FEED_URL|g" \
  -e "s|__SPARKLE_PUBLIC_ED_KEY__|$SPARKLE_PUBLIC_ED_KEY|g" \
  "$APP_DIR/Contents/Info.plist"

echo "$APP_DIR"
