#!/bin/bash

SESSION_ID=$(jq -r '.session_id')
STOP_HOOK_ACTIVE=$(jq -r '.stop_hook_active')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

SCRIPT_DIR="$(dirname $(dirname "$(realpath "$0")"))"
PROJECT_PATH=$($SCRIPT_DIR/shorten_path.sh "$PWD")
MESSAGE=$(cat $HOME/.claude/history.jsonl | jq -s -r ". | map(select(.sessionId | startswith(\"${SESSION_ID}\"))) | sort_by(.timestamp) | .[-1].display // empty")

# If the message is empty, it means there is no display message
# for the last entry of this session. so we skip the notification.
# This can happen when the session is closed before any message is displayed,
# or if there was an error that prevented the message from being generated.
# In either case, we don't want to show a notification with an empty message.
if [ -z "$MESSAGE" ]; then
    exit 0
fi

terminal-notifier \
    -title "✅ Task Completed" \
    -subtitle "${PROJECT_PATH} (${SESSION_ID:0:8})" \
    -message "> ${MESSAGE}" \
    -sound "default" \
    -activate "com.mitchellh.ghostty" \
    -group "claude-code-stop-notification-#${PROJECT_NAME}"
