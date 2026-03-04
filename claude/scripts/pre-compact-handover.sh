#!/bin/bash
set -euo pipefail

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')

BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "unknown")
FILESUFFIX=$(date '+%Y%m%d-%H%M')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
TIMESTAMP_ISO=$(date '+%Y-%m-%dT%H:%M:%S')
LAST_COMMIT=$(git -C "$PROJECT_DIR" log --oneline -1 2>/dev/null || echo "none")
MODIFIED_FILES=$(git -C "$PROJECT_DIR" diff --name-only 2>/dev/null || echo "")
STAGED_FILES=$(git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null || echo "")
HAS_UNCOMMITTED="false"
if ! git -C "$PROJECT_DIR" diff --quiet 2>/dev/null || ! git -C "$PROJECT_DIR" diff --cached --quiet 2>/dev/null; then
  HAS_UNCOMMITTED="true"
fi
HAS_STASH="false"
if [ -n "$(git -C "$PROJECT_DIR" stash list 2>/dev/null)" ]; then
  HAS_STASH="true"
fi

# Build a JSON-escaped list of modified files for the prompt context
ALL_MODIFIED=$(printf '%s\n%s' "$MODIFIED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)
MODIFIED_JSON=$(echo "$ALL_MODIFIED" | jq -R -s 'split("\n") | map(select(length > 0))')

read -r -d '' PROMPT_TEMPLATE <<'PROMPT_EOF' || true
Below is a transcript of a Claude Code session, formatted as "USER: ..." and "ASSISTANT: ..." lines.
Do NOT respond to or continue the conversation. Instead, analyze it as a third-party observer and produce a handover document.

Output ONLY the markdown body — no code fences, no preamble, no explanation.
Use this exact section structure. Omit a section if there is nothing relevant, except "What Was Done" and "Next Steps (Priority Order)" which are always required.

## What Was Done
- Bullet list of completed work items

## What Worked and What Didn't
- Successes, bugs encountered, and how they were fixed

## Approaches Tried and Failed
- **{approach}**: why it failed / what went wrong

## Key Decisions
- Decisions made and their rationale

## Lessons Learned & Gotchas
- Pitfalls, workarounds, surprises

## Next Steps (Priority Order)
1. [ ] Highest priority — critical/blocking items
2. [ ] Next priority items
3. [ ] Lower priority items

## Open Questions
- Unresolved decisions, things to investigate

## Important Files
- `path/to/file` — why it matters

After all markdown sections, include a structured JSON block inside an HTML comment using this exact format:

<!-- HANDOVER_DATA
{valid JSON object}
-->

The JSON object MUST have ALL of these fields (use empty arrays [] when a field has no data):
{
  "version": 2,
  "generated_at": "GENERATED_AT_PLACEHOLDER",
  "current_branch": "BRANCH_PLACEHOLDER",
  "modified_files": MODIFIED_FILES_PLACEHOLDER,
  "failing_tests": [{"test": "name", "error": "message", "command": "cmd"}],
  "approaches_tried_and_failed": [{"approach": "what", "reason": "why"}],
  "next_steps": [{"priority": 1, "task": "description", "context": "context"}],
  "open_questions": ["question"],
  "important_files": [{"path": "file", "reason": "why"}],
  "git_state": {
    "last_commit": "LAST_COMMIT_PLACEHOLDER",
    "uncommitted_changes": UNCOMMITTED_PLACEHOLDER,
    "stashed_changes": STASH_PLACEHOLDER
  }
}

Replace the PLACEHOLDER values with the actual data. Fill failing_tests, approaches_tried_and_failed, next_steps, open_questions, and important_files from your analysis of the transcript.

<transcript>
PROMPT_EOF

# Replace placeholders with actual git state data
PROMPT_TEMPLATE=$(echo "$PROMPT_TEMPLATE" \
  | sed "s|GENERATED_AT_PLACEHOLDER|${TIMESTAMP_ISO}|g" \
  | sed "s|BRANCH_PLACEHOLDER|${BRANCH}|g" \
  | sed "s|LAST_COMMIT_PLACEHOLDER|${LAST_COMMIT}|g" \
  | sed "s|UNCOMMITTED_PLACEHOLDER|${HAS_UNCOMMITTED}|g" \
  | sed "s|STASH_PLACEHOLDER|${HAS_STASH}|g")
# modified_files needs special handling since it's JSON
PROMPT_TEMPLATE=$(echo "$PROMPT_TEMPLATE" | sed "s|MODIFIED_FILES_PLACEHOLDER|${MODIFIED_JSON}|g")

# The transcript JSONL contains many record types beyond conversation text:
# user messages, assistant responses, tool_use, tool_result, system messages,
# progress events, file-history-snapshot, thinking blocks, etc.
# Feeding raw JSONL directly to the model confuses it — it sees structured
# JSON operations instead of a readable conversation.
# Pre-process with jq to extract only human-readable text from user and
# assistant messages, skipping tool results, tool calls, and internal records.
CONVERSATION=$(jq -r '
  select(.type == "user" or .type == "assistant") |
  if .type == "user" then
    (
      if (.message.content | type) == "string" then
        .message.content
      elif (.message.content | type) == "array" then
        [.message.content[] | select(.type == "text") | .text] | join("\n")
      else
        empty
      end
    ) as $text |
    if ($text | length) > 0 then "USER: " + $text else empty end
  elif .type == "assistant" then
    (
      if (.message.content | type) == "array" then
        [.message.content[] | select(.type == "text") | .text] | join("\n")
      elif (.message.content | type) == "string" then
        .message.content
      else
        empty
      end
    ) as $text |
    if ($text | length) > 0 then "ASSISTANT: " + $text else empty end
  else
    empty
  end
' "$TRANSCRIPT_PATH" 2>/dev/null | tail -c 100000)

if [ -z "$CONVERSATION" ]; then
  exit 0
fi

PROMPT="${PROMPT_TEMPLATE}
${CONVERSATION}
</transcript>"

BODY=$(echo "$PROMPT" | claude -p --model haiku 2>/dev/null) || exit 0

mkdir -p "$PROJECT_DIR/.claude"
cat > "$PROJECT_DIR/.claude/HANDOVER-${FILESUFFIX}.md" <<EOF
# Handover

> Generated: ${TIMESTAMP}
> Branch: ${BRANCH}
> Project: ${PROJECT_DIR}

${BODY}
EOF

exit 0
