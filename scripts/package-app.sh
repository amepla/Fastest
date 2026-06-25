#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>   (example: v0.3 or 0.3)" >&2
    exit 1
fi
VERSION="${VERSION#v}"

OUTPUT="releases/v${VERSION}/MacBrowser-v${VERSION}.zip"
mkdir -p "releases/v${VERSION}"
rm -f "$OUTPUT"

./scripts/build-app.sh
ditto -c -k --sequesterRsrc --keepParent "MacBrowser.app" "$OUTPUT"

echo "Packaged $OUTPUT"
