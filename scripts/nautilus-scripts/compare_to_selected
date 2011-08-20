#!/bin/sh
arg2=$(cat $HOME/.beyondcompare/nautilus)
arg1=$(echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | awk 'BEGIN { FS = "\n" } { printf "\"%s\" ", $1 }' | sed -e s#\"\"##)
bcompare $arg1 $arg2