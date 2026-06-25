#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP=MacBrowser.app
CONTENTS="$APP/Contents"
RESOURCES="$CONTENTS/Resources"
ICON_SOURCE="resources/AppIcon.icns"

mkdir -p "$CONTENTS/MacOS" "$RESOURCES"
clang++ -std=c++17 -ObjC++ -fobjc-arc src/main.mm src/BrowserApp.mm -framework Cocoa -framework WebKit -o "$CONTENTS/MacOS/MacBrowser"

ICON_PLIST_ENTRY=""
if [ -f "$ICON_SOURCE" ]; then
    cp "$ICON_SOURCE" "$RESOURCES/AppIcon.icns"
    ICON_PLIST_ENTRY="  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
"
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
  <string>1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
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
echo "Built $APP"
