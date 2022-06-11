#!/bin/bash
# Create on-demand loading completions for some aliases from ../bash_aliases*

# Definitions and bootstrap ----------------------------------------------------

xdg_data=${XDG_DATA_HOME:-$HOME/.local/share}
user_dir=${BASH_COMPLETION_USER_DIR:-${xdg_data}/bash-completion}
comp_dir=${user_dir}/completions
here=$(dirname -- "$(readlink -f -- "$0")")

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

