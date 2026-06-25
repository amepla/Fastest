#!/bin/bash
# Script to create DMG background with installation instructions

OUTPUT_DIR="scripts/.dmg-resources"
mkdir -p "$OUTPUT_DIR"

# Create a simple background PNG with instructions using ImageMagick or system tools
# If ImageMagick not available, create a basic white background with text instructions

BACKGROUND_PNG="$OUTPUT_DIR/dmg-background.png"

# Using sips and text to create background (macOS native)
python3 << 'PYTHON'
from PIL import Image, ImageDraw, ImageFont
import os

width, height = 600, 400
bg_color = (15, 15, 15)  # dark gray/black
img = Image.new('RGB', (width, height), bg_color)
draw = ImageDraw.Draw(img)

# Try to use system font
try:
    font_title = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    font_body = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
except:
    font_title = ImageFont.load_default()
    font_body = ImageFont.load_default()

# Draw text
text_color = (245, 240, 232)  # light cream
title = "MacBrowser Installation"
body_lines = [
    "1. Drag MacBrowser.app to Applications →",
    "",
    "If you see 'is damaged' error:",
    "  Open Terminal and run:",
    "  xattr -d com.apple.quarantine ~/Applications/MacBrowser.app"
]

# Draw title
draw.text((30, 40), title, font=font_title, fill=text_color)

# Draw body text
y_offset = 100
for line in body_lines:
    draw.text((30, y_offset), line, font=font_body, fill=text_color)
    y_offset += 35

img.save("scripts/.dmg-resources/dmg-background.png")
print("Created dmg-background.png")
PYTHON

echo "Background image created at: $BACKGROUND_PNG"
