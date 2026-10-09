#!/usr/bin/env bash

set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

XDG_DATA_HOME="$TMP_DIR/data" bash "$APP_DIR/install-desktop.sh"
DESKTOP_FILE="$TMP_DIR/data/applications/PS2Classics.desktop"

test -f "$DESKTOP_FILE"
grep -Fxq "Exec=\"$APP_DIR/ps2classic-ps2classic/ps2classic-gui\"" "$DESKTOP_FILE"
grep -Fxq "Path=$APP_DIR/ps2classic-ps2classic" "$DESKTOP_FILE"
if command -v desktop-file-validate >/dev/null 2>&1; then
	desktop-file-validate "$DESKTOP_FILE"
fi

printf 'Desktop installer checks passed\n'
