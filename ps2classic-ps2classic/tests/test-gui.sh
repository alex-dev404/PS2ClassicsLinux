#!/usr/bin/env bash

set -euo pipefail

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/out"
printf 'test ISO\n' >"$TMP_DIR/game.iso"
export GUI_TEST_DIR="$TMP_DIR"

cat >"$TMP_DIR/bin/zenity" <<'MOCK_ZENITY'
#!/usr/bin/env bash
set -euo pipefail

if [[ " $* " == *" --list "* ]]; then
	count=0
	[[ -f "$GUI_TEST_DIR/list-count" ]] && read -r count <"$GUI_TEST_DIR/list-count"
	count=$((count + 1))
	printf '%s\n' "$count" >"$GUI_TEST_DIR/list-count"
	if (( count == 1 )); then
		printf 'Gerar PKG PS2 Classics completo (requer pop-fe2)\n'
	else
		printf 'Sair\n'
	fi
elif [[ " $* " == *" --file-selection "* ]]; then
	if [[ " $* " == *" --save "* ]]; then
		printf '%s\n' "$GUI_TEST_DIR/out/game.pkg"
	else
		printf '%s\n' "$GUI_TEST_DIR/game.iso"
	fi
elif [[ " $* " == *" --progress "* ]]; then
	cat >/dev/null
elif [[ " $* " == *" --text-info "* ]]; then
	for arg in "$@"; do
		if [[ "$arg" == --filename=* ]]; then
			cat "${arg#--filename=}" >"$GUI_TEST_DIR/result-log"
		fi
	done
elif [[ " $* " == *" --error "* ]]; then
	printf '%s\n' "$*" >>"$GUI_TEST_DIR/dialog-errors"
elif [[ " $* " == *" --question "* ]]; then
	exit 0
fi
MOCK_ZENITY
chmod +x "$TMP_DIR/bin/zenity"

cat >"$TMP_DIR/bin/dpkg-query" <<'MOCK_DPKG_QUERY'
#!/usr/bin/env bash
package="${@: -1}"
if [[ "$package" == "${MOCK_MISSING_PACKAGE:-}" \
	&& ! -e "$GUI_TEST_DIR/package-$package-installed" ]]; then
	exit 1
fi
printf 'ii \n'
MOCK_DPKG_QUERY
chmod +x "$TMP_DIR/bin/dpkg-query"

cat >"$TMP_DIR/bin/apt-get" <<'MOCK_APT_GET'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$GUI_TEST_DIR/apt-get-args"
if [[ "${1:-}" == install ]]; then
	for arg in "${@:3}"; do
		[[ "$arg" == -* ]] || : >"$GUI_TEST_DIR/package-$arg-installed"
	done
fi
MOCK_APT_GET
chmod +x "$TMP_DIR/bin/apt-get"

cat >"$TMP_DIR/bin/sudo" <<'MOCK_SUDO'
#!/usr/bin/env bash
if [[ "${1:-}" == -v ]]; then
	exit 0
fi
"$@"
MOCK_SUDO
chmod +x "$TMP_DIR/bin/sudo"

cat >"$TMP_DIR/bin/pop-fe2.py" <<'MOCK_POP_FE2'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$@" >"$GUI_TEST_DIR/pop-fe2-args"
if [[ "${MOCK_NO_OUTPUT:-0}" == 1 ]]; then
	exit 0
fi
for arg in "$@"; do
	case "$arg" in
		--ps3-pkg=*) pkg_name="${arg#*=}" ;;
		--output-directory=*) pkg_dir="${arg#*=}" ;;
	esac
done
: "${pkg_name:?missing pkg name}"
: "${pkg_dir:?missing pkg directory}"
printf 'mock package\n' >"$pkg_dir/$pkg_name"
MOCK_POP_FE2
chmod +x "$TMP_DIR/bin/pop-fe2.py"

export PATH="$TMP_DIR/bin:$PATH"
export POP_FE2=pop-fe2.py
export MOCK_NO_OUTPUT=0
"$APP_DIR/ps2classic-gui"
test -s "$TMP_DIR/out/game.pkg"
grep -Fxq "$TMP_DIR/game.iso" "$TMP_DIR/pop-fe2-args"
grep -Fxq -- '--ps3-pkg=game.pkg' "$TMP_DIR/pop-fe2-args"
grep -Fxq -- "--output-directory=$TMP_DIR/out" "$TMP_DIR/pop-fe2-args"

rm -f "$TMP_DIR/out/game.pkg" "$TMP_DIR/list-count"
export MOCK_NO_OUTPUT=1
"$APP_DIR/ps2classic-gui"
grep -q 'sem criar o arquivo esperado' "$TMP_DIR/result-log"

rm -f "$TMP_DIR/list-count" "$TMP_DIR/dialog-errors"
export POP_FE2="$TMP_DIR/missing-tool"
"$APP_DIR/ps2classic-gui"
grep -q 'Não encontrei a ferramenta indicada' "$TMP_DIR/dialog-errors"

rm -f "$TMP_DIR/list-count"
export POP_FE2=pop-fe2.py
export MOCK_MISSING_PACKAGE=zenity
"$APP_DIR/ps2classic-gui"
grep -Fxq 'update' "$TMP_DIR/apt-get-args"
grep -Fxq 'install -y zenity' "$TMP_DIR/apt-get-args"
test -e "$TMP_DIR/package-zenity-installed"

printf 'GUI package-generation checks passed\n'
