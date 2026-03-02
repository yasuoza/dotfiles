#!/usr/bin/env bash
# General-purpose wrapper for the copilot CLI agent.
# Reads the prompt from a file to avoid single-line escaping issues.
#
# Usage:
#   run_copilot.sh <prompt_file> [--resume <session_id>] [--lang <language>]
#
# The prompt file should contain the full task prompt (multi-line is fine).
# Outputs copilot response to stdout.
# On first invocation, prints session ID as the last line:
#   COPILOT_SESSION_ID=<id>
#
# Requirements: copilot CLI installed and on PATH.

set -euo pipefail

PROMPT_FILE=""
SESSION_ID=""
LANG_HINT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resume) SESSION_ID="$2"; shift 2 ;;
    --lang)   LANG_HINT="$2"; shift 2 ;;
    *)        PROMPT_FILE="$1"; shift ;;
  esac
done

if [[ -z "$PROMPT_FILE" || ! -f "$PROMPT_FILE" ]]; then
  echo "Error: prompt file not found: ${PROMPT_FILE:-<not specified>}" >&2
  exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

# Append language instruction
if [[ -n "$LANG_HINT" ]]; then
  PROMPT="${PROMPT}

Write your output in ${LANG_HINT}."
else
  PROMPT="${PROMPT}

Match the language of the codebase's comments and documentation in your output."
fi

# Build copilot command args
ARGS=(--yolo --no-ask-user --silent --stream on --model gpt-5.3-codex)
if [[ -n "$SESSION_ID" ]]; then
  ARGS+=(--resume "$SESSION_ID")
fi
ARGS+=(--prompt "$PROMPT")

copilot "${ARGS[@]}"

# Extract and output session ID (first invocation only)
if [[ -z "$SESSION_ID" ]]; then
  LATEST_SESSION=$(ls -t ~/.copilot/session-state/ 2>/dev/null | head -1)
  if [[ -n "$LATEST_SESSION" ]]; then
    echo ""
    echo "COPILOT_SESSION_ID=${LATEST_SESSION}"
  fi
fi
