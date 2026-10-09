#!/usr/bin/env bash

set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GUI="$APP_DIR/ps2classic-ps2classic/ps2classic-gui"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DESKTOP_FILE="$DESKTOP_DIR/PS2Classics.desktop"

if [[ ! -x "$GUI" ]]; then
	printf 'O lançador gráfico não foi encontrado ou não é executável: %s\n' "$GUI" >&2
	exit 1
fi

mkdir -p "$DESKTOP_DIR"
{
	printf '[Desktop Entry]\n'
	printf 'Version=1.0\n'
	printf 'Type=Application\n'
	printf 'Name=PS2 Classics\n'
	printf 'Comment=Criptografa, descriptografa e empacota imagens PS2 Classics\n'
	printf 'Exec="%s"\n' "$GUI"
	printf 'Path=%s\n' "$(dirname -- "$GUI")"
	printf 'Terminal=false\n'
	printf 'Categories=Utility;\n'
	printf 'StartupNotify=true\n'
} >"$DESKTOP_FILE"

printf 'Atalho instalado em %s\n' "$DESKTOP_FILE"
