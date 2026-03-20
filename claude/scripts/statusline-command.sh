#!/bin/bash

# Read JSON input
input=$(cat)

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name' | sed 's/ context//;s/ //g')

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

# Get context and rate limit info
context_info=""
now=$(date +%s)
remaining=$(echo "$input" | jq -r '.context_window.used_percentage // empty | if . != "" then (. * 10 + 0.5 | floor) / 10 else . end')
rate_5h=$(echo "$input" | jq -r '(.rate_limits.five_hour.used_percentage // null) | if . then round | tostring else empty end')
rate_7d=$(echo "$input" | jq -r '(.rate_limits.seven_day.used_percentage // null) | if . then round | tostring else empty end')
reset_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
reset_7d=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

dim=$'\033[2m'
undim=$'\033[22m'

fmt_remaining() {
    local diff=$(( $1 - now ))
    [ "$diff" -le 0 ] && return
    local d=$(( diff / 86400 )) h=$(( diff % 86400 / 3600 )) m=$(( diff % 3600 / 60 ))
    if [ "$d" -gt 0 ]; then
        printf '%s(%dd%dh)%s' "$dim" "$d" "$h" "$undim"
    elif [ "$h" -gt 0 ]; then
        printf '%s(%dh%02dm)%s' "$dim" "$h" "$m" "$undim"
    else
        printf '%s(%dm)%s' "$dim" "$m" "$undim"
    fi
}

ctx_info=""
[ -n "$remaining" ] && ctx_info=" ctx:${remaining}%"

rate_parts=()
[ -n "$rate_5h" ] && rate_parts+=("5h$([ -n "$reset_5h" ] && fmt_remaining "$reset_5h"):${rate_5h}%")
[ -n "$rate_7d" ] && rate_parts+=("7d$([ -n "$reset_7d" ] && fmt_remaining "$reset_7d"):${rate_7d}%")

rate_info=""
if [ ${#rate_parts[@]} -gt 0 ]; then
    joined=""
    for p in "${rate_parts[@]}"; do
        joined="${joined:+${joined} ${dim}·${undim} }${p}"
    done
    rate_info=" ${dim}·${undim} ${joined}"
fi

# Build:
# Line 1: $cwd $git_info ctx:$remaining%
# Line 2: [$model] $rate_info
printf "\033[32m[%s]\033[0m%s%s" "$short_cwd" "$git_info" "$ctx_info"
printf '\n'
printf "%s%s" "$model" "$rate_info"
