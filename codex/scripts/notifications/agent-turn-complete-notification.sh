#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/session-name.sh"

INPUT="${1-}"
if [ -z "$INPUT" ]; then
    INPUT=$(cat)
fi

PROJECT_NAME=$(sanitize_osc_field "$(printf '%s' "$INPUT" | jq -r '.cwd // empty | split("/")[-1] // empty')")
if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME=$(sanitize_osc_field "$(basename "$PWD")")
fi

SESSION_NAME=$(resolve_codex_session_name "$INPUT")
DISPLAY_NAME=$(sanitize_osc_field "${SESSION_NAME:-$PROJECT_NAME}")
if [[ -z "$DISPLAY_NAME" ]]; then
    DISPLAY_NAME="$PROJECT_NAME"
fi

REASON_RAW=$(printf '%s' "$INPUT" | jq -r '
    ."last-assistant-message"
    // .last_assistant_message
    // empty
')
REASON=$(sanitize_osc_field "$REASON_RAW")
if [[ -z "$REASON" ]]; then
    exit 0
fi
TITLE=$(sanitize_osc_field "Codex ${DISPLAY_NAME}")
MESSAGE="$REASON"

send_codex_notification "$TITLE" "$MESSAGE" "codex-agent-turn-complete-#${DISPLAY_NAME}"
