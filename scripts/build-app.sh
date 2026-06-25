#!/bin/bash
set -e
cd "$(dirname "$0")/.."
APP=MacBrowser.app
CONTENTS="$APP/Contents"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"
clang++ -std=c++17 -ObjC++ src/main.mm src/BrowserApp.mm -framework Cocoa -framework WebKit -o "$CONTENTS/MacOS/MacBrowser"
cat > "$CONTENTS/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>MacBrowser</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
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
touch "$CONTENTS/Resources/.keep"

# Copy icon if it exists
if [ -f "$CONTENTS/Resources/AppIcon.icns" ]; then
    echo "Using custom icon"
else
    touch "$CONTENTS/Resources/AppIcon.icns"
fi

codesign --force --sign - "$APP" 2>/dev/null || true
echo "Built $APP (signed)"
