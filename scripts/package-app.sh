#!/bin/bash
set -e
cd "$(dirname "$0")/.."

VERSION="${1:-v0.2}"
OUTPUT="releases/$VERSION/MacBrowser-$VERSION.zip"
mkdir -p "releases/$VERSION"
rm -f "$OUTPUT"

./scripts/build-app.sh
zip -r -y "$OUTPUT" "MacBrowser.app"

echo "Packaged $OUTPUT"
