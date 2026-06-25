# MacBrowser

MacBrowser is a minimal native macOS browser prototype implemented with Objective-C++ and WebKit (`WKWebView`). It demonstrates a compact, premium-styled UI and provides a foundation for features like tabs, bookmarks and history.

> **Note:** The GitHub repository is named [Fastest](https://github.com/amepla/Fastest); the distributed app is **MacBrowser**.

## Features

- Dark, restrained UI focused on hierarchy and readability
- Controls: `Home`, `Back`, `Forward`, `Reload`
- Address field with URL detection, `https://` completion, and DuckDuckGo search fallback
- Built-in styled home page (landing) for presentation and testing
- JavaScript enabled in `WKWebView`, back/forward gestures supported

## Installation (Recommended for Users)

1. Download the latest `MacBrowser-v*.dmg` from [Releases](https://github.com/amepla/Fastest/releases)
2. Open the DMG and drag `MacBrowser.app` to **Applications**
3. Launch from Applications

If you see "MacBrowser.app is damaged", see [Troubleshooting](#troubleshooting-macbrowserapp-is-damaged).

## Quick start (build & run)

```bash
./scripts/build.sh
./MacBrowser
```

## Build a macOS app bundle

```bash
./scripts/build-app.sh          # dev build (version 0.0.0-dev)
APP_VERSION=v0.4 ./scripts/build-app.sh   # versioned build
open MacBrowser.app
```

## Release & deploy

### Recommended: tag push → CI

```bash
git commit -am "prepare v0.4"
git push origin main
git tag v0.4
git push origin v0.4
```

GitHub Actions builds the DMG and publishes it with `gh`. The app `CFBundleShortVersionString` matches the tag (e.g. `0.4`).

### Local release via gh CLI

```bash
gh auth login
python3 -m venv .venv && .venv/bin/pip install -r requirements.txt   # first time only
./scripts/release.sh v0.4
```

`release.sh` requires a clean, pushed `main` branch, builds the DMG, and runs `gh release create`.

## Project layout

| Path | Purpose |
|------|---------|
| `src/` | Application source (Objective-C++) |
| `resources/Info.plist` | Bundle metadata template (CMake) |
| `resources/AppIcon.icns` | App icon (optional, not committed) |
| `scripts/build.sh` | Build CLI binary |
| `scripts/build-app.sh` | Build `.app` bundle |
| `scripts/create-dmg.sh` | Create versioned DMG |
| `scripts/release.sh` | Build + publish via `gh` |
| `scripts/package-app.sh` | Create `.zip` (alternative distribution) |
| `scripts/lib/version.sh` | Shared version normalization |
| `requirements.txt` | Python deps for DMG background |
| `.github/workflows/build.yml` | CI build on PR/push |
| `.github/workflows/release.yml` | CI release on tag push |

## Troubleshooting: "MacBrowser.app is damaged"

```bash
xattr -d com.apple.quarantine ~/Applications/MacBrowser.app
open ~/Applications/MacBrowser.app
```

Ad-hoc signed builds (`codesign -`) are expected to trigger Gatekeeper on download. Notarization is not set up yet.

## License

MIT — see `LICENSE`.
