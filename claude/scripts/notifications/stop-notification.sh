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

TITLE="✅ ${PROJECT_PATH} (${SESSION_ID:0:8})"

# Notification routing by environment:
#   1. tmux(local) -> ssh -> tmux(remote) : OSC 777 with double tmux passthrough
#   2. tmux(local) -> ssh                 : OSC 777 with single tmux passthrough
#   3. VS Code Remote SSH                 : OSC 777 bare (Terminal Notification extension)
#   4. SSH without TTY (other)            : no notification path available
#   5. Local macOS                        : terminal-notifier
if [[ -n $SSH_TTY ]]; then
    if [[ -n $TMUX ]]; then
        # Case 1: remote tmux unwraps outer, local tmux unwraps inner
        printf '\ePtmux;\e\ePtmux;\e\e\e\e]777;notify;%s;%s\a\e\e\\\e\\' "$TITLE" "> $MESSAGE" > /dev/tty
    else
        # Case 2: local tmux unwraps the single passthrough
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "> $MESSAGE" > /dev/tty
    fi
elif [[ "$TERM_PROGRAM" == "vscode" ]]; then
    # Case 3: VS Code parses OSC 777 on the client side
    printf '\e]777;notify;%s;%s\a' "$TITLE" "> $MESSAGE" > /dev/tty
elif [[ -n $SSH_CONNECTION ]]; then
    # Case 4: no TTY and no VS Code — nothing we can send to
    exit 0
else
    # Case 5: local macOS with Ghostty
    terminal-notifier \
        -title "$TITLE" \
        -message "> ${MESSAGE}" \
        -sound "default" \
        -activate "com.mitchellh.ghostty" \
        -group "claude-code-stop-notification-#${PROJECT_NAME}"
fi
