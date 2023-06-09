#!/usr/bin/env bash
#
# install-bash_aliases.sh - Installer for bash_aliases_{min,root} and pythonrc.py
#
# This file is part of <https://github.com/MestreLion/scripts/home>
# Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
#------------------------------------------------------------------------------
set -Eeuo pipefail  # exit on any error
trap '>&2 echo "error: line $LINENO, status $?: $BASH_COMMAND"' ERR
#------------------------------------------------------------------------------

mode=${1:-auto}  # auto (or blank), download, symlink
url=https://github.com/MestreLion/scripts/raw/main/home

#------------------------------------------------------------------------------
usage()     { echo "Usage: ${0##*/} [auto|download|symlink]" >&2; exit 1; }
user_home() { getent passwd -- "${1:-$USER}" | cut -d: -f6; }
is_root()   { (( EUID == 0 )); }  # POSIX: [ "$(id -u)" -eq 0 ]
#------------------------------------------------------------------------------
if is_root; then suffix=root; else suffix=min; fi
here=$(dirname "$(readlink -f "$0")")
file=$here/bash_aliases_$suffix
home=$(user_home "")  # intended $HOME even if running via sudo without -H
xdg=${XDG_CONFIG_HOME:-$home/.config}

case "$mode" in	auto|symlink);; download) download=1;; *) usage;; esac
if [[ "$mode" == auto && -f "$file" ]]; then download=0; fi
if ! ((download)) && ! [[ -f "$file" ]]; then
	echo "$file not found. Clone the repository or use standalone mode" >&2
	exit 1
fi
#------------------------------------------------------------------------------
create() {
	local source=$1
	local dest=$2
	if ((download)); then
		wget --hsts-file="$xdg"/wget-hsts -O "$dest" -- "$url/$source"
	else
		ln -vTfrs -- "$here/$source" "$dest"
	fi
}
# shellcheck disable=SC2174
mkdir -vp -m 0700 -- "$xdg"
create "${file##*/}" "$home"/.bash_aliases
create pythonrc.py   "$xdg"/pythonrc.py
