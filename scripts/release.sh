#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=lib/version.sh
source "$(dirname "$0")/lib/version.sh"

TAG="${1:-}"
SKIP_BUILD=0
NOTES_FILE=""

shift || true
while [ $# -gt 0 ]; do
    case "$1" in
        --skip-build)
            SKIP_BUILD=1
            ;;
        --notes)
            shift
            NOTES_FILE="${1:-}"
            ;;
        *)
            if [ -z "$NOTES_FILE" ] && [ -f "$1" ]; then
                NOTES_FILE="$1"
            else
                echo "Unknown argument: $1" >&2
                exit 1
            fi
            ;;
    esac
    shift || true
done

if [ -z "$TAG" ]; then
    echo "Usage: $0 <tag> [notes-file] [--skip-build]" >&2
    echo "Example: $0 v0.4" >&2
    echo "         $0 v0.4 RELEASE_NOTES.md" >&2
    exit 1
fi

validate_tag "$TAG"
TAG="$(normalize_tag "$TAG")"

if ! command -v gh >/dev/null 2>&1; then
    echo "Error: GitHub CLI (gh) is required — https://cli.github.com/" >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "Error: gh is not authenticated. Run: gh auth login" >&2
    exit 1
fi

if [ "$SKIP_BUILD" -eq 0 ]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "Error: working tree has uncommitted changes. Commit or stash before releasing." >&2
        exit 1
    fi

    LOCAL_HEAD="$(git rev-parse HEAD)"
    if ! git rev-parse "@{u}" >/dev/null 2>&1; then
        echo "Warning: no upstream branch configured; tag may not match remote main." >&2
    else
        REMOTE_HEAD="$(git rev-parse "@{u}")"
        if [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
            echo "Error: local branch is not synced with remote. Push or pull before releasing." >&2
            exit 1
        fi
    fi

    echo "==> Building DMG for ${TAG}"
    export APP_VERSION="$TAG"
    ./scripts/create-dmg-background.sh
    ./scripts/create-dmg.sh "$TAG"
fi

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

App version: ${TAG#v}

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
        --notes-file "$TMP_NOTES" \
        --target "$(git rev-parse HEAD)"
fi

RELEASE_URL=$(gh release view "$TAG" --json url -q .url)
echo "Published: ${RELEASE_URL}"
echo "Recommended: git push origin ${TAG}  # keeps tag in sync for CI history"
