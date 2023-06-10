#!/bin/bash
# Update bash_aliases_root with changes from bash_aliases_min
# To re-generate the patch:
#	diff -u bash_aliases_{min,root}
cd "$(dirname "$(readlink -f "$0")")" && cp bash_aliases_{min,root} &&
patch bash_aliases_root <<'EOF'
--- bash_aliases_min	2023-06-10 14:51:22.724617318 -0300
+++ bash_aliases_root	2023-06-10 18:59:24.633286204 -0300
@@ -1,5 +1,5 @@
-# Minimal quality-of-life aliases and settings, including PS1
-# Copy (or symlink) to ~/.bash_aliases, or use ./install-bash_aliases.sh
+# Bare-bones quality-of-life aliases and settings, including PS1, for root
+# Copy (or symlink) to /root/.bash_aliases, or use ./install-bash_aliases.sh
 # See https://github.com/MestreLion/scripts/home/
 #
 # Copyright (C) 2023 Rodrigo Silva (MestreLion) <linux@rodrigosilva.com>
@@ -12,12 +12,6 @@
 # Use ~/.profile or ~/.pam_environment to properly set them.
 export BLOCK_SIZE="'1"
 
-# No more (poorly and half-) translated --help and man pages, please!
-# https://www.gnu.org/software/gettext/manual/html_node/Locale-Environment-Variables.html
-export LANGUAGE=en_US:en
-export LC_ALL=en_US.UTF-8
-export LC_NUMERIC=pt_BR.UTF-8  # might require sudo locale-gen pt_BR.UTF-8
-
 # >>>>> XDG defs <<<<<----------------------------------------------------------
 
 xdg_config=${XDG_CONFIG_HOME:-$HOME/.config}
@@ -115,10 +109,8 @@
 alias la="ll -A"
 alias path="echo \$PATH"
 alias fstab="sudo editor /etc/fstab"
-alias open="xdg-open"
 alias trash="trash-put"  # requires trash-cli. Do NOT alias rm, affects functions
-alias mand="dwww-man"    # requires dwww
-alias dd-progress="sudo dd status=progress bs=1M iflag=fullblock,count_bytes"
+alias dd-progress="dd status=progress bs=1M iflag=fullblock,count_bytes"
 alias dd-nocache="dd-progress oflag=nocache,sync"
 alias dfd='df -H -x tmpfs -x squashfs -x devtmpfs'
 alias duh='du -sbh --si'
@@ -132,16 +124,10 @@
 alias ntfs-fix-perms-group="chmod -R a=rw,o-w,a+X"
 alias 7z-ultra="7z a -mx"  # requires p7zip
 
-# healthchecks.io
-alias hc-open='open "https://healthchecks.io"'
-alias hc-list='exists sch && { sch list --all || :; } || hc-open'
-alias hc='hc-list'
-
 # systemd
-alias status='systemctl status'  # no sudo for status
-for cmd in start stop restart reload; do
+for cmd in status start stop restart reload; do
 	# shellcheck disable=SC2139
-	alias "${cmd}=sudo systemctl ${cmd}"
+	alias "${cmd}=systemctl ${cmd}"
 done
 unset cmd
 
@@ -158,7 +144,6 @@
 timestamp() { _datefmt '+%Y%m%d%H%M%S'      "${1:-}" '@'; }
 epoch()     { _datefmt '+%s'                "${1:-}"; }
 
-ubuntu-package() { open "http://packages.ubuntu.com/search?searchon=names&suite=all&section=all&keywords=$1"; }
 f2b() { local j=${1:-sshd}; sudo fail2ban-client status "$j"; }
 make-parallel() { make -j "$(nproc --ignore=2)" "$@"; }
 
@@ -509,7 +494,7 @@
 # shellcheck disable=SC2140
 PS1="${c[RESET]}${c[BOLD]}"\
 "${c[PURPLE]}\t ${c[CYAN]}\$(_shell_level)${c[GREEN]}\u@\h ${c[BLUE]}\w "\
-"${c[RED]}\$(__git_ps1 '%s ')${c[YELLOW]}\$(_format_exitcode)${c[BLUE]}\\$ "\
+"${c[RED]}\$(__git_ps1 '%s ')${c[YELLOW]}\$(_format_exitcode)${c[RED]}\\$ "\
 "${c[RESET]}"
 
 # >>>>> Settings <<<<<----------------------------------------------------------
EOF
