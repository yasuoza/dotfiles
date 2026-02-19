#!/bin/bash
# PreToolUse hook: auto-approve Bash commands starting with "copilot "
# Workaround for Claude Code bug #20449 where allow rules don't prevent
# permission prompts for non-read-only commands.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ "$COMMAND" == copilot\ * ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "copilot commands are auto-approved via PreToolUse hook"
    }
  }'
fi

exit 0
