# MacBrowser

Native macOS browser — dark UI, DuckDuckGo as start page and search.

## Install

1. Open **[Releases](https://github.com/amepla/Fastest/releases)** and download the latest `MacBrowser-v*.dmg`
2. Open the DMG and drag **MacBrowser.app** into **Applications**
3. Launch **MacBrowser** from Applications

**Requirements:** macOS 10.15 or later

## If macOS says the app is damaged

This happens because the app was downloaded from the internet. Run in Terminal:

```bash
xattr -d com.apple.quarantine ~/Applications/MacBrowser.app
open ~/Applications/MacBrowser.app
```

## License

MIT — see [LICENSE](LICENSE).
