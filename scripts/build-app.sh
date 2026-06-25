#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=lib/version.sh
source "$(dirname "$0")/lib/version.sh"

APP=MacBrowser.app
CONTENTS="$APP/Contents"
RESOURCES="$CONTENTS/Resources"
ICON_SOURCE="resources/AppIcon.icns"

if [ -n "${APP_VERSION:-}" ]; then
    APP_VERSION="$(tag_to_app_version "$APP_VERSION")"
elif [ -n "${1:-}" ]; then
    APP_VERSION="$(tag_to_app_version "$1")"
else
    APP_VERSION="0.0.0-dev"
fi

BUILD_NUMBER="${BUILD_NUMBER:-$(git rev-list --count HEAD 2>/dev/null || echo 0)}"

mkdir -p "$CONTENTS/MacOS" "$RESOURCES"
clang++ -std=c++17 -ObjC++ -fobjc-arc -Wall -Wextra \
    src/main.mm src/BrowserApp.mm \
    -framework Cocoa -framework WebKit -framework QuartzCore \
    -o "$CONTENTS/MacOS/MacBrowser"

ICON_PLIST_ENTRY=""
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$RESOURCES/AppIcon.icns"
    ICON_PLIST_ENTRY="  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
"
fi

if [ -f "resources/newtab.html" ]; then
    cp "resources/newtab.html" "$RESOURCES/newtab.html"
fi

cat > "$CONTENTS/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>MacBrowser</string>
${ICON_PLIST_ENTRY}  <key>CFBundleIdentifier</key>
  <string>com.amepla.MacBrowser</string>
  <key>CFBundleName</key>
  <string>MacBrowser</string>
  <key>CFBundleDisplayName</key>
  <string>MacBrowser</string>
  <key>CFBundleVersion</key>
  <string>${BUILD_NUMBER}</string>
  <key>CFBundleShortVersionString</key>
  <string>${APP_VERSION}</string>
  <key>LSMinimumSystemVersion</key>
  <string>10.15</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
EOF

chmod +x "$CONTENTS/MacOS/MacBrowser"
codesign --force --sign - "$APP" 2>/dev/null || true
echo "Built $APP (version ${APP_VERSION}, build ${BUILD_NUMBER})"
