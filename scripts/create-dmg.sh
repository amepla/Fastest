#!/bin/bash
set -e
cd "$(dirname "$0")/.."

# Build the app first
./scripts/build-app.sh

DMG_NAME="MacBrowser-v0.2.dmg"
DMG_PATH="$DMG_NAME"
TEMP_DIR=$(mktemp -d)
MOUNT_DIR="$TEMP_DIR/mount"
STAGING_DIR="$TEMP_DIR/staging"

cleanup() {
    hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

mkdir -p "$STAGING_DIR"
cp -r MacBrowser.app "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

# Create DMG
rm -f "$DMG_PATH"
hdiutil create -volname "MacBrowser" -srcfolder "$STAGING_DIR" -ov -format UDRW "$DMG_PATH"

# Mount and customize
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_PATH" | grep "/dev/" | awk '{print $1}')
MOUNT_DIR="/Volumes/MacBrowser"

# Set icon positions and window properties
osascript <<EOF
tell application "Finder"
  tell disk "MacBrowser"
    open
    delay 1
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {100, 100, 650, 500}
    set arrangement of icon view of container window to arranged by name
    
    set position of item "MacBrowser.app" of container window to {120, 150}
    set position of item "Applications" of container window to {420, 150}
    
    set background picture of icon view options of container window to file ".background/background.png"
    delay 1
    close container window
    eject disk "MacBrowser"
  end tell
end tell
EOF

# Convert to read-only DMG
hdiutil detach "$MOUNT_DIR" 2>/dev/null || true
hdiutil convert "$DMG_PATH" -format UDZO -o "${DMG_PATH%.dmg}.final.dmg"
mv "${DMG_PATH%.dmg}.final.dmg" "$DMG_PATH"

echo "Created $DMG_PATH"
