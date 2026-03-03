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
    --resume)
      if [[ $# -lt 2 ]]; then
        echo "Error: --resume requires a session ID argument" >&2
        exit 1
      fi
      SESSION_ID="$2"; shift 2 ;;
    --lang)
      if [[ $# -lt 2 ]]; then
        echo "Error: --lang requires a language argument" >&2
        exit 1
      fi
      LANG_HINT="$2"; shift 2 ;;
    -*)
      echo "Error: unknown option: $1" >&2
      exit 1 ;;
    *)
      PROMPT_FILE="$1"; shift ;;
  esac
done

if [[ -z "$PROMPT_FILE" ]]; then
  echo "Error: prompt file not specified" >&2
  echo "Usage: run_copilot.sh <prompt_file> [--resume <session_id>] [--lang <language>]" >&2
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: prompt file not found: ${PROMPT_FILE}" >&2
  exit 1
fi

if [[ ! -s "$PROMPT_FILE" ]]; then
  echo "Error: prompt file is empty: ${PROMPT_FILE}" >&2
  exit 1
fi

if ! command -v copilot &>/dev/null; then
  echo "Error: copilot CLI not found on PATH" >&2
  exit 1
fi

PROMPT=$(<"$PROMPT_FILE")

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
  SESSION_STATE_DIR="${HOME}/.copilot/session-state"
  if [[ -d "$SESSION_STATE_DIR" ]]; then
    LATEST_SESSION=$(ls -t "$SESSION_STATE_DIR" 2>/dev/null | head -1)
    if [[ -n "$LATEST_SESSION" ]]; then
      echo ""
      echo "COPILOT_SESSION_ID=${LATEST_SESSION}"
    fi
  else
    echo "" >&2
    echo "Warning: session-state directory not found at ${SESSION_STATE_DIR}" >&2
    echo "Session ID could not be extracted." >&2
  fi
fi
