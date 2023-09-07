#!/bin/bash
# Intentionally not executable, so it's not taken as a script by Nautilus
# Run as `bash install.sh`

# For a good default icons viewer, run gtk3-icon-browser from apt package gtk-3-examples

here=$(dirname "$(readlink -f "$0")")

set_icon() {
	local path=$1
	local icon=$2
	printf '%s\t%s\n' "$path" "$icon" >&2
	gio set "$path" "metadata::custom-icon-name" "$icon"
}

# Scripts icons: comment '# icon-name: ICON_NAME' in script
while IFS= read -r script; do
	# I'm sure there are better ways to do that...
	icon=$(grep -Exm1 '#\s*icon-name\s*:\s*\S+\s*' "$script" | cut -d: -f2 | grep -Eo '\S+')
	if [[ -z "$icon" ]]; then continue; fi
	set_icon "$script" "$icon"
done < <(find -L "$here" -type f -executable)

# Subdirs icons: '.icon-name' hidden file in subdir containing (only) ICON_NAME
while IFS= read -r path; do
	icon=$(<"$path")
	if [[ -z "$icon" ]]; then continue; fi
	set_icon "$(dirname "$path")" "$icon"
done < <(find -L "$here" -type f -name '.icon-name')

#TODO: finish installing!
#nautilus=${XDG_DATA_HOME:-"$HOME"/.local/share}/nautilus/scripts

#TODO: run 'nautilus -q' to apply changes in the scripts dirs (new, deleted or renamed scripts)
