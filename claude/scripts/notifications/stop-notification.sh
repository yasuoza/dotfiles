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

# Notification routing:
#   Linux (EC2 etc.): OSC 777 via printf. tmux requires Ptmux passthrough.
#   Local macOS (Ghostty): terminal-notifier.
if [[ "$(uname)" == "Darwin" ]]; then
    # Local macOS
    if ! command -v terminal-notifier &>/dev/null; then
        exit 0
    fi
    terminal-notifier \
        -title "$TITLE" \
        -message "> ${MESSAGE}" \
        -sound "default" \
        -activate "com.mitchellh.ghostty" \
        -group "claude-code-stop-notification-#${PROJECT_NAME}"
else
    # Linux: OSC 777 (SSH_CONNECTION は hook に引き継がれないため OS で判定)
    if [[ -n $TMUX ]]; then
        # tmux: ユーザーが今フォーカス中のアクティブペインに書き込む。
        # 非アクティブペイン宛だと allow-passthrough all 設定でもパススルーが外側ターミナルに届かないため。
        CLIENT_SESSION=$(tmux list-clients -F '#{client_session}' 2>/dev/null | head -1)
        if [[ -n $CLIENT_SESSION ]]; then
            PANE_TTY=$(tmux display-message -p -t "${CLIENT_SESSION}:" '#{pane_tty}' 2>/dev/null)
        else
            PANE_TTY=$(tmux display-message -p -t "${TMUX_PANE:-}" '#{pane_tty}' 2>/dev/null)
        fi
        if [[ -z $PANE_TTY || ! -w $PANE_TTY ]]; then
            exit 0
        fi
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "> $MESSAGE" > "$PANE_TTY"
    else
        if ! { exec > /dev/tty; } 2>/dev/null; then
            exit 0
        fi
        printf '\e]777;notify;%s;%s\a' "$TITLE" "> $MESSAGE" > /dev/tty
    fi
fi
