#!/bin/bash
# Create on-demand loading completions for some aliases from ../bash_aliases*

# Definitions and bootstrap ----------------------------------------------------

xdg_data=${XDG_DATA_HOME:-$HOME/.local/share}
user_dir=${BASH_COMPLETION_USER_DIR:-${xdg_data}/bash-completion}
comp_dir=${user_dir}/completions
here=$(dirname -- "$(readlink -f -- "$0")")

exists() { type "$@" &>/dev/null; }
escape() { printf '%q' "$@"; }
create_dirs() {
	local path=$1
	local mode=${2:-}
	local opts=(); if [[ "$mode" ]]; then opts+=(--mode "$mode"); fi
	if ! [[ -d "$path" ]]; then mkdir --parents "${opts[@]}" -- "$path"; fi
}


# Main dirs
create_dirs "$xdg_data" 700
create_dirs "$comp_dir"

# Static completions
if ! [[ "$user_dir" == "$here" ]]; then
	create_dirs "$user_dir"/bash_completion.d
	cp --no-clobber -r -t "$user_dir" -- "$here"/bash_completion{,.d}
fi

# ------------------------------------------------------------------------------

systemctl_aliases() {
	local target=/usr/share/bash-completion/completions/systemctl
	local cmds=(start stop restart reload)
	cat > "$comp_dir"/status <<-EOF
		# Created by ${here}/install.sh

		# Alternative:
		#source -- $(escape "$target") &>/dev/null || return 1
		#complete -F _systemctl -- status ${cmds[@]}

		__load_completion systemctl || return 1
		eval \$(complete -p systemctl) status ${cmds[@]}
	EOF
	for cmd in "${cmds[@]}"; do
		ln -f -s -- status "$comp_dir"/"$cmd"
	done
} && systemctl_aliases

argcomplete_aliases() {
	local cmds=(
		pipx
	)
	local cmd
	for cmd in "${cmds[@]}"; do
		if ! exists "$cmd"; then continue; fi
		printf '# Created by %s/install.sh\n' "$here" |
		cat - <(register-python-argcomplete "$cmd") > "$comp_dir"/"$cmd"
	done
} && exists register-python-argcomplete && argcomplete_aliases
