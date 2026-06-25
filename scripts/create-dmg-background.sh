#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

OUTPUT_DIR="scripts/.dmg-resources"
mkdir -p "$OUTPUT_DIR"
BACKGROUND_PNG="$OUTPUT_DIR/dmg-background.png"

ensure_python() {
    if [ ! -x ".venv/bin/python3" ]; then
        echo "Creating local Python venv (.venv)..."
        python3 -m venv .venv
        .venv/bin/pip install -q -r requirements.txt
    fi
    PYTHON=".venv/bin/python3"
}

if [ -x ".venv/bin/python3" ]; then
    PYTHON=".venv/bin/python3"
elif python3 -c "from PIL import Image" 2>/dev/null; then
    PYTHON="python3"
else
    ensure_python
fi

"$PYTHON" - "$BACKGROUND_PNG" <<'PYTHON'
import sys

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    print("Pillow is required. Run: python3 -m venv .venv && .venv/bin/pip install -r requirements.txt", file=sys.stderr)
    sys.exit(1)

output_path = sys.argv[1]
width, height = 600, 400
bg_color = (15, 15, 15)
img = Image.new("RGB", (width, height), bg_color)
draw = ImageDraw.Draw(img)

try:
    font_title = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    font_body = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
except OSError:
    font_title = ImageFont.load_default()
    font_body = ImageFont.load_default()

text_color = (245, 240, 232)
title = "MacBrowser Installation"
body_lines = [
    "1. Drag MacBrowser.app to Applications →",
    "",
    "If you see 'is damaged' error:",
    "  Open Terminal and run:",
    "  xattr -d com.apple.quarantine ~/Applications/MacBrowser.app",
]

draw.text((30, 40), title, font=font_title, fill=text_color)
y_offset = 100
for line in body_lines:
    draw.text((30, y_offset), line, font=font_body, fill=text_color)
    y_offset += 35

img.save(output_path)
print(f"Created {output_path}")
PYTHON
