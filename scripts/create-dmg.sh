#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>   (example: v0.3 or 0.3)" >&2
    exit 1
fi
VERSION="${VERSION#v}"

./scripts/build-app.sh

DMG_NAME="MacBrowser-v${VERSION}.dmg"
BACKGROUND_SRC="scripts/.dmg-resources/dmg-background.png"
TEMP_DIR=$(mktemp -d)
STAGING_DIR="$TEMP_DIR/staging"
MOUNT_DIR="/Volumes/MacBrowser"

cleanup() {
    hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

mkdir -p "$STAGING_DIR"
cp -r MacBrowser.app "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

if [ -f "$BACKGROUND_SRC" ]; then
    mkdir -p "$STAGING_DIR/.background"
    cp "$BACKGROUND_SRC" "$STAGING_DIR/.background/background.png"
fi

rm -f "$DMG_NAME"
hdiutil create -volname "MacBrowser" -srcfolder "$STAGING_DIR" -ov -format UDRW "$DMG_NAME"

hdiutil attach -readwrite -noverify -noautoopen "$DMG_NAME" >/dev/null

if [ -f "$BACKGROUND_SRC" ]; then
    osascript <<'EOF'
tell application "Finder"
  tell disk "MacBrowser"
    open
    delay 1
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {100, 100, 650, 500}
    set arrangement of icon view of container window to not arranged
    set position of item "MacBrowser.app" of container window to {120, 150}
    set position of item "Applications" of container window to {420, 150}
    set background picture of icon view options of container window to file ".background:background.png"
    delay 1
    close container window
    eject disk "MacBrowser"
  end tell
end tell
EOF
else
    osascript <<'EOF'
tell application "Finder"
  tell disk "MacBrowser"
    open
    delay 1
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {100, 100, 650, 500}
    set position of item "MacBrowser.app" of container window to {120, 150}
    set position of item "Applications" of container window to {420, 150}
    delay 1
    close container window
    eject disk "MacBrowser"
  end tell
end tell
EOF
fi

hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
hdiutil convert "$DMG_NAME" -format UDZO -o "${DMG_NAME%.dmg}.final.dmg"
mv "${DMG_NAME%.dmg}.final.dmg" "$DMG_NAME"

echo "Created $DMG_NAME"
