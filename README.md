# MacBrowser

MacBrowser is a minimal native macOS browser prototype implemented with Objective-C++ and WebKit (`WKWebView`). It demonstrates a compact, premium-styled UI and provides a foundation for features like tabs, bookmarks and history.

## Features

- Dark, restrained UI focused on hierarchy and readability
- Controls: `Home`, `Back`, `Forward`, `Reload`
- Address field with automatic `https://` scheme completion and basic validation
- Built-in styled home page (landing) for presentation and testing
- JavaScript enabled in `WKWebView`, back/forward gestures supported

## Installation (Recommended for Users)

The easiest way to install MacBrowser is via the DMG installer:

1. Download the latest `MacBrowser-v*.dmg` from [Releases](https://github.com/amepla/Fastest/releases)
2. Open the DMG file
3. Drag `MacBrowser.app` to the `Applications` folder
4. Open `Applications` → `MacBrowser` to launch

If you see "MacBrowser.app is damaged" error, see [Troubleshooting](#troubleshooting-macbrowserapp-is-damaged) below.

## Quick start (build & run)

Open a terminal in the project directory and run:

```bash
./scripts/build.sh
```

Run the binary:

```bash
./MacBrowser
```

## Build a macOS app bundle

To make the app launchable by double-clicking its icon, build the `.app` bundle from the project root:

```bash
./scripts/build-app.sh
```

The result will be `MacBrowser.app`. Open it in Finder or run it from Terminal:

```bash
open MacBrowser.app
```

## Release & deploy (GitHub CLI)

Publishing a release is handled entirely through the [GitHub CLI](https://cli.github.com/):

```bash
# one-time setup
gh auth login

# build DMG and publish to GitHub Releases
./scripts/release.sh v0.3
```

Optional: pass a custom notes file as the second argument:

```bash
./scripts/release.sh v0.3 RELEASE_NOTES.md
```

### Automated CI release

Pushing a version tag also triggers a GitHub Actions workflow that builds the DMG and publishes it with `gh`:

```bash
git tag v0.3
git push origin v0.3
```

Or run the workflow manually from the Actions tab (`workflow_dispatch`).

## Troubleshooting: "MacBrowser.app is damaged"

If you see "MacBrowser.app is damaged and can't be opened" when launching from Finder:

1. This is macOS quarantine — the system flags downloaded apps for safety
2. Remove the quarantine attribute:

```bash
xattr -d com.apple.quarantine MacBrowser.app
```

3. Then run it again:

```bash
open MacBrowser.app
```

## Project layout

- `src/main.mm` — application entry point
- `src/BrowserApp.h` — application class declaration
- `src/BrowserApp.mm` — UI implementation and WebKit integration
- `resources/Info.plist` — bundle metadata for CMake builds
- `scripts/build.sh` — convenience build script
- `scripts/build-app.sh` — build `.app` bundle
- `scripts/create-dmg.sh` — create versioned DMG installer
- `scripts/release.sh` — build and publish via `gh release`
- `.github/workflows/release.yml` — CI release on tag push
- `CMakeLists.txt` — optional CMake support
- `.gitignore`, `LICENSE`, `README.md`

## Contributing

Contributions are welcome. Suggested workflow:

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/your-feature`)
3. Make changes, build and test locally
4. Push and open a pull request with a descriptive title and summary

## License

This project is released under the MIT License. See the `LICENSE` file for details.
