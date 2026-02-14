#!/bin/bash
set -euo pipefail

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')

BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "unknown")
FILESUFFIX=$(date '+%Y%m%d-%H%M')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

read -r -d '' PROMPT_TEMPLATE <<'PROMPT_EOF' || true
Below is a transcript of a Claude Code session, formatted as "USER: ..." and "ASSISTANT: ..." lines.
Do NOT respond to or continue the conversation. Instead, analyze it as a third-party observer and produce a handover document.

Output ONLY the markdown body — no code fences, no preamble, no explanation.
Use this exact section structure. Omit a section if there is nothing relevant, except "What Was Done" and "Next Steps" which are always required.

## What Was Done
- Bullet list of completed work items

## What Worked and What Didn't
- Successes, bugs encountered, and how they were fixed

## Key Decisions
- Decisions made and their rationale

## Lessons Learned & Gotchas
- Pitfalls, workarounds, surprises

## Next Steps
- [ ] Actionable TODO items with enough context to execute without reading the transcript

## Important Files
- `path/to/file` — why it matters

<transcript>
PROMPT_EOF

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
