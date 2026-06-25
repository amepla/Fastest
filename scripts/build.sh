#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
clang++ -std=c++17 -ObjC++ -fobjc-arc -Wall -Wextra src/main.mm src/BrowserApp.mm -framework Cocoa -framework WebKit -framework QuartzCore -o MacBrowser

echo "Build complete: ./MacBrowser"
