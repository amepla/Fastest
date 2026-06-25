# MacBrowser

Open-source native macOS browser built with Objective-C++ and WebKit. Full source code is in this repository — you can read, audit, and fork it.

- Dark minimal UI
- Start page and search: [DuckDuckGo](https://duckduckgo.com)
- No analytics, no bundled trackers — see `src/` yourself

## Install

1. Download the latest `MacBrowser-v*.dmg` from **[Releases](https://github.com/amepla/Fastest/releases)**
2. Open the DMG — drag **MacBrowser.app** onto the **Applications** folder (arrow on the background)
3. Open **Applications** → **MacBrowser**

**Requires:** macOS 10.15+

### "App is damaged"

macOS blocks downloaded apps until you remove quarantine:

```bash
xattr -d com.apple.quarantine ~/Applications/MacBrowser.app
open ~/Applications/MacBrowser.app
```

The app is ad-hoc signed (`codesign -`). Building from source (below) is the most transparent option.

## Build from source

```bash
git clone https://github.com/amepla/Fastest.git
cd Fastest

# CLI binary
./scripts/build.sh
./MacBrowser

# .app bundle
./scripts/build-app.sh
open MacBrowser.app
```

Or with CMake:

```bash
cmake -S . -B build
cmake --build build
open build/MacBrowser.app
```

**Dependencies:** Xcode Command Line Tools (`clang++`, Cocoa, WebKit)

## Project structure

```
src/           Browser source code
resources/     App bundle metadata
scripts/       Build scripts
CMakeLists.txt Optional CMake build
```

## Fork & contribute

Forks welcome. The entire browser logic lives in three files under `src/`. Pull requests appreciated.

## License

MIT — see [LICENSE](LICENSE).
