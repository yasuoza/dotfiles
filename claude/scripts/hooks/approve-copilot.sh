#!/bin/bash
# PreToolUse hook: auto-approve copilot-related Bash commands.
# - Commands starting with "copilot " (direct copilot CLI)
# - Commands containing "run_copilot.sh" (skill wrapper, including heredoc pipes)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ "$COMMAND" == copilot\ * ]] || [[ "$COMMAND" == *run_copilot.sh* ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "copilot commands are auto-approved via PreToolUse hook"
    }
  }'
fi

exit 0
