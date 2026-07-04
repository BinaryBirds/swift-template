#!/usr/bin/env bash
set -euo pipefail

log() { printf -- "** %s\n" "$*" >&2; }
error() { printf -- "** ERROR: %s\n" "$*" >&2; }
fatal() { error "$@"; exit 1; }

swift build -c release

INSTALL_DIR="${1:-/usr/local/bin}"

if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p "$INSTALL_DIR"
fi

sudo install .build/release/swift-template "${INSTALL_DIR}/swift-template"
