#!/bin/bash

SESSION_ID=$(jq -r '.session_id')
STOP_HOOK_ACTIVE=$(jq -r '.stop_hook_active')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

SCRIPT_DIR="$(dirname $(dirname "$(realpath "$0")"))"
PROJECT_PATH=$($SCRIPT_DIR/shorten_path.sh "$PWD")
MESSAGE=$(cat $HOME/.claude/history.jsonl | jq -s -r ". | map(select(.sessionId | startswith(\"${SESSION_ID}\"))) | sort_by(.timestamp) | .[-1].display")

terminal-notifier \
    -title "✅ Task Completed" \
    -subtitle "${PROJECT_PATH} (${SESSION_ID:0:8})" \
    -message "> ${MESSAGE}" \
    -sound "default" \
    -activate "com.mitchellh.ghostty" \
    -group "claude-code-stop-notification-#${PROJECT_NAME}"
