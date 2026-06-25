#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=lib/version.sh
source "$(dirname "$0")/lib/version.sh"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>   (example: v0.4 or 0.4)" >&2
    exit 1
fi
validate_tag "$VERSION"
TAG="$(normalize_tag "$VERSION")"
VERSION="${TAG#v}"

OUTPUT="releases/${TAG}/MacBrowser-${TAG}.zip"
mkdir -p "releases/${TAG}"
rm -f "$OUTPUT"

export APP_VERSION="$TAG"
./scripts/build-app.sh
ditto -c -k --sequesterRsrc --keepParent "MacBrowser.app" "$OUTPUT"

echo "Packaged $OUTPUT"
