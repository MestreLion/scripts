#!/bin/sh
quoted=$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | awk 'BEGIN { FS = "\n" } { printf "\"%s\" ", $1 }' | sed -e s#\"\"##)
echo "$quoted" > $HOME/.beyondcompare/nautilus