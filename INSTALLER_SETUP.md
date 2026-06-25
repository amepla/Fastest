# MacBrowser Installation & Logo Setup

This guide explains how to create a professional DMG installer with custom logo for MacBrowser.

## Step 1: Create a Custom Logo

Use the prompt in `LOGO_PROMPT.txt` to generate a premium logo via:
- **ChatGPT with DALL-E** (free with Plus subscription)
- **Midjourney** (Discord-based, high quality)
- **Leonardo.AI** (free tier available)

### Requirements:
- Format: PNG, 1024×1024 pixels
- Background: **Transparent** (important!)
- Style: Modern, minimalist, premium
- No overly bright or playful colors

### After generating the logo:

1. Save the PNG file as `MacBrowser-logo.png` in the project root
2. Convert it to macOS ICNS format:

```bash
./scripts/png-to-icns.sh MacBrowser-logo.png
```

3. Copy the resulting `.icns` file to the app resources:

```bash
cp MacBrowser-logo.icns MacBrowser.app/Contents/Resources/AppIcon.icns
```

4. Rebuild the app to apply the icon:

```bash
./scripts/build-app.sh
```

## Step 2: Create DMG Installer

Once you have a logo (even a placeholder), create the DMG:

```bash
./scripts/create-dmg-background.sh
./scripts/create-dmg.sh
```

This produces `MacBrowser-v0.2.dmg` with:
- Drag-and-drop installation interface
- Instructions for handling macOS quarantine warning
- Professional layout with custom background

## Step 3: Distribute

Upload the DMG to GitHub Releases:

```bash
gh release upload v0.2 MacBrowser-v0.2.dmg
```

Users can now:
1. Download the `.dmg` file
2. Open it and drag `MacBrowser.app` to `Applications`
3. If they see "damaged" error, they'll see clear instructions in the DMG

## Troubleshooting

### "ImageMagick not found"
The `create-dmg-background.sh` script uses Python with PIL (Pillow). Install it:

```bash
pip3 install pillow
```

### Icon not showing in Finder
- Ensure the `.icns` file is copied to `MacBrowser.app/Contents/Resources/AppIcon.icns`
- Rebuild the app and clear Finder cache: `killall Finder`

### DMG creation fails
Some versions of macOS require `hdiutil` permissions. Run with:

```bash
sudo ./scripts/create-dmg.sh
```

## Next Steps

- Add a custom color scheme in `.app` Info.plist
- Create a website (GitHub Pages) with screenshots
- Set up GitHub Actions for automated builds
