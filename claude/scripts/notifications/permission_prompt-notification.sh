#!/bin/bash

SESSION_ID=$(jq -r '.session_id')
STOP_HOOK_ACTIVE=$(jq -r '.stop_hook_active')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

SCRIPT_DIR="$(dirname $(dirname "$(realpath "$0")"))"
PROJECT_PATH=$($SCRIPT_DIR/shorten_path.sh "$PWD")
MESSAGE=$(cat $HOME/.claude/history.jsonl | jq -s -r ". | map(select(.sessionId | startswith(\"${SESSION_ID}\"))) | sort_by(.timestamp) | .[-1].display // \"(empty message)\"")

TITLE="⚠️ ${PROJECT_PATH} (${SESSION_ID:0:8})"

# Notification routing:
#   SSH (VS Code Remote SSH): OSC 777 via printf. tmux requires Ptmux passthrough.
#   Local macOS (Ghostty):    terminal-notifier.
if [[ -n $SSH_CONNECTION ]]; then
    if [[ -n $TMUX ]]; then
        # SSH + tmux: single passthrough (remote tmux unwraps → client receives bare OSC 777)
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "> $MESSAGE" > /dev/tty
    else
        # SSH without tmux: bare OSC 777
        printf '\e]777;notify;%s;%s\a' "$TITLE" "> $MESSAGE" > /dev/tty
    fi
else
    # Local macOS
    terminal-notifier \
        -title "$TITLE" \
        -message "> ${MESSAGE}" \
        -sound "default" \
        -activate "com.mitchellh.ghostty" \
        -group "claude-code-permission_prompt-notification-#${PROJECT_NAME}"
fi
