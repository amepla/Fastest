# MacBrowser

MacBrowser is a minimal native macOS browser prototype implemented with Objective-C++ and WebKit (`WKWebView`). It demonstrates a compact, premium-styled UI and provides a foundation for features like tabs, bookmarks and history.

## Features

- Dark, restrained UI focused on hierarchy and readability
- Controls: `Home`, `Back`, `Forward`, `Reload`
- Address field with automatic `https://` scheme completion and basic validation
- Built-in styled home page (landing) for presentation and testing
- JavaScript enabled in `WKWebView`, back/forward gestures supported

## Quick start (build & run)

Open a terminal in the project directory and run:

```bash
cd "$(pwd)"
./scripts/build.sh
# or directly:
clang++ -std=c++17 -ObjC++ src/main.mm src/BrowserApp.mm -framework Cocoa -framework WebKit -o MacBrowser
```

Run the binary:

```bash
./MacBrowser
```

## Build a macOS app bundle

To make the app launchable by double-clicking its icon, build the `.app` bundle from the project root:

```bash
cd "$(pwd)"
./scripts/build-app.sh
```

The result will be `MacBrowser.app`. Open it in Finder or run it from Terminal:

```bash
open MacBrowser.app
```

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
- `scripts/build.sh` — convenience build script
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

## Contact

If you'd like, I can add GitHub Actions for automated macOS builds, enable GitHub Pages for screenshots/docs, or implement tab/bookmark support inside the app — tell me which you'd prefer next.
