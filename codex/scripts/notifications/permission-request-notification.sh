#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/session-name.sh"

INPUT=$(cat)

PROJECT_NAME=$(sanitize_osc_field "$(printf '%s' "$INPUT" | jq -r '.cwd // empty | split("/")[-1] // empty')")
if [[ -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME=$(sanitize_osc_field "$(basename "$PWD")")
fi

SESSION_NAME=$(resolve_codex_session_name "$INPUT")
DISPLAY_NAME=$(sanitize_osc_field "${SESSION_NAME:-$PROJECT_NAME}")
if [[ -z "$DISPLAY_NAME" ]]; then
    DISPLAY_NAME="$PROJECT_NAME"
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // "tool"')
DESCRIPTION=$(printf '%s' "$INPUT" | jq -r '.tool_input.description // empty')
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

DETAIL="$DESCRIPTION"
if [[ -z "$DETAIL" ]]; then
    DETAIL="$COMMAND"
fi
if [[ -z "$DETAIL" ]]; then
    DETAIL="Approval required"
fi

TITLE=$(sanitize_osc_field "⚠️ Codex ${DISPLAY_NAME}")
MESSAGE=$(sanitize_osc_field "${TOOL_NAME}: ${DETAIL}")

send_codex_notification "$TITLE" "$MESSAGE" "codex-permission-request-#${DISPLAY_NAME}"
