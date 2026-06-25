#!/bin/bash
set -euo pipefail

# Converts PNG icon to macOS ICNS format.
# Usage: ./scripts/png-to-icns.sh path/to/icon.png [output.icns]

if [ -z "${1:-}" ]; then
    echo "Usage: $0 path/to/icon.png [output.icns]" >&2
    exit 1
fi

PNG_FILE="$1"
ICNS_FILE="${2:-resources/AppIcon.icns}"

if [ ! -f "$PNG_FILE" ]; then
    echo "Error: PNG file not found: $PNG_FILE" >&2
    exit 1
fi

TEMP_ICONSET=$(mktemp -d)
trap 'rm -rf "$TEMP_ICONSET"' EXIT
ICONSET_DIR="$TEMP_ICONSET/MacBrowser.iconset"
mkdir -p "$ICONSET_DIR"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$PNG_FILE" --out "$ICONSET_DIR/icon_${size}x${size}.png" >/dev/null
    sips -z "$((size * 2))" "$((size * 2))" "$PNG_FILE" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" >/dev/null
done

mkdir -p "$(dirname "$ICNS_FILE")"
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE"

echo "Created $ICNS_FILE"
echo "Rebuild the app: ./scripts/build-app.sh"
