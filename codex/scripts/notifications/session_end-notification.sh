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
    .["input-messages"][-1]
    // .input_messages[-1]
    // ."last-user-message"
    // .last_user_message
    // ."last-assistant-message"
    // .last_assistant_message
    // .reason
    // .message
    // .summary
    // .text
    // .status
    // "Task completed"
')
REASON=$(sanitize_osc_field "$REASON_RAW")
TITLE=$(sanitize_osc_field "Codex ${DISPLAY_NAME}")
MESSAGE="$REASON"

# Use the same OSC 777 routing for the legacy notify callback and command
# hooks. The common helper also handles tmux passthrough and missing ttys.
send_osc777_notification "$TITLE" "$MESSAGE"
