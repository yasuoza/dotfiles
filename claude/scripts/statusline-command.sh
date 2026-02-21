#!/bin/bash

# Read JSON input
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')

# Shorten cwd path (first 2 / ... / last 2, replace $HOME with ~)
shorten_path() {
    local target="$1"
    local path="${target/#$HOME/~}"
    IFS='/' read -r -a parts <<< "$path"
    local clean_parts=()
    for part in "${parts[@]}"; do
        [[ -n "$part" ]] && clean_parts+=("$part")
    done
    parts=("${clean_parts[@]}")
    local len=${#parts[@]}
    if (( len > 4 )); then
        local head="${parts[0]}/${parts[1]}"
        local tail="${parts[len-2]}/${parts[len-1]}"
        if [[ "$path" == /* ]]; then
            echo "/${head}/.../${tail}"
        else
            echo "${head}/.../${tail}"
        fi
    else
        echo "$path"
    fi
}

short_cwd=$(shorten_path "$cwd")

# Get git branch and status (skip optional locks)
git_info=""
if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)

    # Check for staged changes
    staged=""
    if ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
        staged="+"
    fi

    # Check for unstaged changes
    unstaged=""
    if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null; then
        unstaged="-"
    fi

    if [ -n "$branch" ]; then
        git_info=$' [\033[36m'"${staged}${unstaged}${branch}"$'\033[0m]'
    fi
fi

# Get context usage
context_info=""
remaining=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$remaining" ]; then
    context_info="(ctx:${remaining}%)"
fi

# Build:
# $cwd $git_info
# [$model](ctx:$remaining)
# cwd path in green inside brackets
printf "\033[32m[%s]\033[0m%s" "$short_cwd" "$git_info"
printf '\n'
printf "[%s]%s" "$model" "$context_info"
