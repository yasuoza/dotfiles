#!/bin/bash

# stdin is consumed once - store it
INPUT=$(cat)

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty')
STOP_HOOK_ACTIVE=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // empty')

if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/notifications/session-name.sh"
PROJECT_PATH=$("$SCRIPT_DIR/shorten_path.sh" "$PWD")
SESSION_NAME=$(resolve_claude_session_name "$INPUT" "$SESSION_ID")
DISPLAY_NAME=$(sanitize_notification_field "${SESSION_NAME:-$PROJECT_PATH}")
if [[ -z "$DISPLAY_NAME" ]]; then
    DISPLAY_NAME=$(sanitize_notification_field "$PROJECT_PATH")
fi

# Use the Notification event's own message instead of re-deriving it from
# history.jsonl. Sanitize the same way as stop-notification.sh: strip control
# chars (ESC/BEL etc. would otherwise corrupt the OSC 777 sequence), collapse
# to a single line, trim, and cap the length (character-safe for multi-byte
# UTF-8).
MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // "(empty message)"' \
    | tr -d '\000-\010\013\014\016-\037' | tr '\n\r' '  ' | tr -s ' ' \
    | sed 's/^ *//; s/ *$//' \
    | perl -CSD -ne 'chomp; print substr($_, 0, 200), "\n"')

TITLE="⚠️ ${DISPLAY_NAME} (${SESSION_ID:0:8})"

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
        -message "${MESSAGE}" \
        -sound "default" \
        -activate "com.mitchellh.ghostty" \
        -group "claude-code-permission_prompt-notification-#${DISPLAY_NAME}"
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
        printf '\ePtmux;\e\e]777;notify;%s;%s\a\e\\' "$TITLE" "$MESSAGE" > "$PANE_TTY"
    elif { exec > /dev/tty; } 2>/dev/null; then
        printf '\e]777;notify;%s;%s\a' "$TITLE" "$MESSAGE" > /dev/tty
    fi
fi
