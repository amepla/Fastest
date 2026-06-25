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
cp MacBrowser-logo.icns resources/AppIcon.icns
```

4. Rebuild the app to apply the icon:

```bash
./scripts/build-app.sh
```

## Step 2: Create DMG Installer

Once you have a logo (even a placeholder), create the DMG:

```bash
pip3 install pillow   # required for DMG background
./scripts/create-dmg-background.sh
./scripts/create-dmg.sh v0.3
```

This produces `MacBrowser-v0.3.dmg` with:

- Drag-and-drop installation interface
- Instructions for handling macOS quarantine warning
- Professional layout with custom background (when Pillow is installed)

## Step 3: Publish via GitHub CLI

All releases are published through `gh`:

```bash
gh auth login
./scripts/release.sh v0.3
```

The script will:

1. Build the DMG background and installer
2. Create a GitHub Release (or upload to an existing one)
3. Attach `MacBrowser-v0.3.dmg` as a release asset

### CI alternative

Push a tag to trigger automated release:

```bash
git tag v0.3
git push origin v0.3
```

## Troubleshooting

### Pillow not installed

The `create-dmg-background.sh` script uses Python with Pillow:

```bash
pip3 install pillow
```

### Icon not showing in Finder

- Ensure `resources/AppIcon.icns` exists before running `./scripts/build-app.sh`
- Clear Finder cache: `killall Finder`

### DMG creation fails

Some versions of macOS require `hdiutil` permissions. Run with:

```bash
sudo ./scripts/create-dmg.sh v0.3
```

## Next Steps

- Add a custom color scheme in `resources/Info.plist`
- Create a website (GitHub Pages) with screenshots
- Releases are automated via `.github/workflows/release.yml`
