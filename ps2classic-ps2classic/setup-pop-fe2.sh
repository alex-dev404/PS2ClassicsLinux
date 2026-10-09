#!/usr/bin/env bash

set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
POP_FE2_DIR="$APP_DIR/external/pop-fe2"
PYTHON="${PYTHON:-python3}"

if ! command -v git >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
	printf 'Instale git, make e as ferramentas de compilação antes de continuar.\n' >&2
	exit 1
fi

if [[ ! -d "$POP_FE2_DIR/.git" ]]; then
	if [[ -e "$POP_FE2_DIR" ]]; then
		printf 'O diretório existe, mas não é uma instalação Git do pop-fe2: %s\n' "$POP_FE2_DIR" >&2
		exit 1
	fi
	git clone --depth 1 https://github.com/sahlberg/pop-fe2.git "$POP_FE2_DIR"
fi

git -C "$POP_FE2_DIR" submodule update --init --depth 1 PSL1GHT make_npdata
git -C "$POP_FE2_DIR/make_npdata" fetch --depth 1 origin wip/hadess/modern-linux
git -C "$POP_FE2_DIR/make_npdata" checkout --detach FETCH_HEAD

if [[ ! -d "$POP_FE2_DIR/atracdenc/.git" ]]; then
	if [[ -e "$POP_FE2_DIR/atracdenc" ]]; then
		printf 'O diretório do helper atracdenc existe, mas não é um repositório Git: %s\n' "$POP_FE2_DIR/atracdenc" >&2
		exit 1
	fi
	git clone --depth 1 --recurse-submodules --branch cstint-fix \
		https://github.com/sahlberg/atracdenc.git "$POP_FE2_DIR/atracdenc"
fi

if [[ ! -x "$POP_FE2_DIR/.venv/bin/python" ]]; then
	"$PYTHON" -m venv "$POP_FE2_DIR/.venv"
fi

"$POP_FE2_DIR/.venv/bin/python" -m pip install --upgrade pip
"$POP_FE2_DIR/.venv/bin/python" -m pip install \
	pillow pycryptodome requests pycdlib ecdsa pygubu yt-dlp \
	PyPDF2 tkinterdnd2 rarfile setuptools

(cd -- "$POP_FE2_DIR/PSL1GHT/tools/ps3py" && \
	"$POP_FE2_DIR/.venv/bin/python" setup.py build_ext --inplace)
make -C "$POP_FE2_DIR/make_npdata/Linux"
(cd -- "$POP_FE2_DIR/atracdenc/src" && \
	cmake . && make)
mkdir -p "$POP_FE2_DIR/ART"

printf '\nInstalação concluída. Abra a interface com:\n  %s/ps2classic-gui\n' "$APP_DIR"
