#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

TAG="${1:-}"
if [ -z "$TAG" ]; then
    echo "Usage: $0 <tag> [release-notes-file]" >&2
    echo "Example: $0 v0.3" >&2
    echo "         $0 v0.3 notes.md" >&2
    exit 1
fi

TAG="${TAG#v}"
TAG="v${TAG}"
NOTES_FILE="${2:-}"

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is required — https://cli.github.com/" >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh is not authenticated. Run: gh auth login" >&2
    exit 1
fi

echo "==> Building DMG for ${TAG}"
./scripts/create-dmg-background.sh
./scripts/create-dmg.sh "$TAG"

DMG="MacBrowser-${TAG}.dmg"
if [ ! -f "$DMG" ]; then
    echo "Error: expected artifact not found: $DMG" >&2
    exit 1
fi

TMP_NOTES=$(mktemp)
trap 'rm -f "$TMP_NOTES"' EXIT

if [ -n "$NOTES_FILE" ] && [ -f "$NOTES_FILE" ]; then
    cp "$NOTES_FILE" "$TMP_NOTES"
else
    cat > "$TMP_NOTES" <<EOF
## MacBrowser ${TAG}

1. Download \`${DMG}\`
2. Open the DMG and drag **MacBrowser.app** to **Applications**
3. Launch from Applications

### Troubleshooting

If macOS reports the app is damaged:

\`\`\`bash
xattr -d com.apple.quarantine ~/Applications/MacBrowser.app
\`\`\`
EOF
fi

echo "==> Publishing ${TAG} via gh"
if gh release view "$TAG" >/dev/null 2>&1; then
    echo "Release ${TAG} exists — uploading asset"
    gh release upload "$TAG" "$DMG" --clobber
else
    gh release create "$TAG" "$DMG" \
        --title "MacBrowser ${TAG}" \
        --notes-file "$TMP_NOTES"
fi

RELEASE_URL=$(gh release view "$TAG" --json url -q .url)
echo "Published: ${RELEASE_URL}"
