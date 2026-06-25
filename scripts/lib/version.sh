#!/bin/bash
# Shared version helpers for build and release scripts.

normalize_tag() {
    local raw="${1:-}"
    raw="${raw#v}"
    printf 'v%s' "$raw"
}

tag_to_app_version() {
    local tag
    tag="$(normalize_tag "${1:-}")"
    printf '%s' "${tag#v}"
}

validate_tag() {
    local tag
    tag="$(normalize_tag "${1:-}")"
    if [[ ! "$tag" =~ ^v[0-9]+(\.[0-9]+)*$ ]]; then
        echo "Invalid version tag: ${1} (expected format: v0.4)" >&2
        return 1
    fi
}
