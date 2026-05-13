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
        -group "claude-code-permission_prompt-notification-#${PROJECT_NAME}"
else
    # Linux: OSC 777 (SSH_CONNECTION は hook に引き継がれないため OS で判定)
    #
    # `claude agents` のバックグラウンドセッションでは hook がスーパーバイザー
    # 配下で動くため $TMUX も /dev/tty も使えない。$TMUX 有無で分岐せず、tmux
    # サーバーに直接問い合わせて「ユーザーがアタッチ中で最後にアクティブだった
    # クライアント」の focused pane に書き込む（非アクティブペインだと
    # allow-passthrough all でも外側ターミナルに届かないため）。
    PANE_TTY=""
    if command -v tmux >/dev/null 2>&1; then
        CLIENT_SESSION=$(tmux list-clients -F '#{client_activity} #{client_session}' 2>/dev/null \
            | sort -rn | head -1 | awk '{print $2}')
        if [[ -n $CLIENT_SESSION ]]; then
            PANE_TTY=$(tmux display-message -p -t "${CLIENT_SESSION}:" '#{pane_tty}' 2>/dev/null)
        fi
    fi

    if [[ -n $PANE_TTY && -w $PANE_TTY ]]; then
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "> $MESSAGE" > "$PANE_TTY"
    elif { exec > /dev/tty; } 2>/dev/null; then
        printf '\e]777;notify;%s;%s\a' "$TITLE" "> $MESSAGE" > /dev/tty
    fi
fi
