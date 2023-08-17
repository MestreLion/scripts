#!/bin/bash
here=$(dirname "$(readlink -f "$0")")

while IFS= read -r script; do
	# I'm sure there are better ways to do that...
	icon=$(grep -Exm1 '#\s*icon-name\s*:\s*\S+\s*' "$script" | cut -d: -f2 | grep -Eo '\S+')
	if [[ -z "$icon" ]]; then continue; fi
	gio set "$script" "metadata::custom-icon-name" "$icon"
done < <(find "$here" -type f -executable)

#TODO: finish installing!
#nautilus=${XDG_DATA_HOME:-"$HOME"/.local/share}/nautilus/scripts
