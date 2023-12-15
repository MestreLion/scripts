#!/usr/bin/env bash
#
# install-bash_aliases.sh - Installer for bash_aliases_{min,root} and pythonrc.py
#
# This file is part of <https://github.com/MestreLion/scripts/tree/main/home>
# Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
# License: GPLv3 or later, at your choice. See <http://www.gnu.org/licenses/gpl>
#------------------------------------------------------------------------------
set -Eeuo pipefail  # exit on any error
trap '>&2 echo "error: line $LINENO, status $?: $BASH_COMMAND"' ERR
#------------------------------------------------------------------------------

mode=${1:-auto}  # auto (or blank), download, symlink
server=${2:-}
url=https://github.com/MestreLion/scripts/raw/main/home
download=1

#------------------------------------------------------------------------------
usage()     { echo "Usage: ${0##*/} [auto|download|symlink] [server]" >&2; exit 1; }
is_root()   { (( EUID == 0 )); }  # EUID set by bash. POSIX: [ "$(id -u)" -eq 0 ]
user_home() {
	if type getent &>/dev/null; then
		getent passwd -- "${1:-$(id -un)}" | cut -d: -f6
	else
		awk -F: -v uid=$EUID '$3 == uid {print $6}' /etc/passwd
	fi
}

#------------------------------------------------------------------------------
if is_root; then suffix=root; elif [[ "$server" ]]; then suffix=min; else suffix=min; fi
here=$(dirname "$(readlink -f "$0")")
file=$here/bash_aliases_$suffix
home=$(user_home)  # intended $HOME even if running via sudo without -H
xdg=${XDG_CONFIG_HOME:-$home/.config}

case "$mode" in
	auto) if [[ -f "$file" ]]; then download=0; fi;;
	download);;
	symlink) download=0;;
	*) usage;;
esac
if ! ((download)) && ! [[ -f "$file" ]]; then
	echo "$file not found. Clone the repository or use download mode" >&2
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
if [[ -f "$home"/.wget-hsts ]]; then mv -v -- "$home"/.wget-hsts "$xdg"/wget-hsts; fi
create "${file##*/}" "$home"/.bash_aliases
create pythonrc.py   "$xdg"/pythonrc.py
