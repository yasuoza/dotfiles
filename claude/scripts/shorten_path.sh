#!/bin/bash

set -e

# Function to shorten a file path for display
# Usage: shorten_path [path]
# If no argument is provided, it defaults to the current directory ($PWD).
# Behavior matches zsh's %-2~/.../%2~ (First 2 dirs ... Last 2 dirs)

# Use the provided argument or default to current directory
target="${1:-$PWD}"

# 1. Replace $HOME with ~
path="${target/#$HOME/~}"

# 2. Split path into an array based on slash separator
IFS='/'
read -r -a parts <<< "$path"

# Remove empty elements (caused by leading or repeated slashes)
clean_parts=()
for part in "${parts[@]}"; do
    [[ -n "$part" ]] && clean_parts+=("$part")
done
parts=("${clean_parts[@]}")

len=${#parts[@]}

# 3. Abbreviation logic: Only shorten if depth exceeds 4
# Structure: [First 2] ... [Last 2]
if (( len > 3 )); then
    head="${parts[0]}/${parts[1]}"
    tail="${parts[len-1]}"

    # If the path starts with '/' and was not replaced by '~', prepending '/' is necessary
    if [[ "$path" == /* ]]; then
        echo "/${head}/.../${tail}"
    else
        echo "${head}/.../${tail}"
    fi
else
    # Return the original path if it is short enough
    echo "$path"
fi
