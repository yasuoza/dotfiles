#!/usr/bin/env bash
# Read-only review wrapper for the copilot CLI agent.
# Runs copilot with write/shell tools denied so it can only review, not modify code.
# Reads the prompt from stdin (pipe or heredoc).
#
# Usage:
#   cat <<'EOF' | run_copilot.sh [--lang <language>]
#   ...review prompt...
#   EOF
#
# Outputs copilot response to stdout.
#
# Requirements: copilot CLI installed and on PATH.

set -euo pipefail

LANG_HINT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
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
      echo "Error: unexpected argument: $1 (prompt is read from stdin)" >&2
      exit 1 ;;
  esac
done

if ! command -v copilot &>/dev/null; then
  echo "Error: copilot CLI not found on PATH" >&2
  exit 1
fi

PROMPT="$(cat)"

if [[ -z "$PROMPT" ]]; then
  echo "Error: no prompt received on stdin" >&2
  exit 1
fi

# Append language instruction
if [[ -n "$LANG_HINT" ]]; then
  PROMPT="${PROMPT}

Write your output in ${LANG_HINT}."
else
  PROMPT="${PROMPT}

Match the language of the codebase's comments and documentation in your output."
fi

# Build copilot command args (read-only: deny write and shell tools)
ARGS=(--no-ask-user --silent --stream on --model gpt-5.3-codex)
ARGS+=(--deny-tool 'write' --deny-tool 'shell')
ARGS+=(--prompt "$PROMPT")

copilot "${ARGS[@]}"
