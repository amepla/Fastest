#!/bin/bash
set -e

# Converts PNG icon to macOS ICNS format
# Usage: ./scripts/png-to-icns.sh path/to/icon.png

if [ -z "$1" ]; then
    echo "Usage: $0 path/to/icon.png"
    exit 1
fi

PNG_FILE="$1"
ICNS_FILE="${PNG_FILE%.png}.icns"

# Create temporary directory for icon set
TEMP_ICONSET=$(mktemp -d)
ICONSET_DIR="$TEMP_ICONSET/MacBrowser.iconset"
mkdir -p "$ICONSET_DIR"

# Generate various sizes required for ICNS
for size in 16 32 64 128 256 512; do
    sips -z "$size" "$size" "$PNG_FILE" --out "$ICONSET_DIR/icon_${size}x${size}.png" 2>/dev/null || true
    sips -z "$((size*2))" "$((size*2))" "$PNG_FILE" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" 2>/dev/null || true
done

# Convert to ICNS
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

rm -rf "$TEMP_ICONSET"

echo "Created $ICNS_FILE"
echo "To use this icon, copy it to: MacBrowser.app/Contents/Resources/AppIcon.icns"
