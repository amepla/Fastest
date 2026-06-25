#!/bin/bash
set -e
cd "$(dirname "$0")/.."
clang++ -std=c++17 -ObjC++ src/main.mm src/BrowserApp.mm -framework Cocoa -framework WebKit -o MacBrowser

echo "Build complete: ./MacBrowser"
