#!/bin/bash
set -euo pipefail

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd')

BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "unknown")
FILESUFFIX=$(date '+%Y%m%d-%H%M')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

read -r -d '' PROMPT <<'PROMPT_EOF' || true
You are analyzing a Claude Code conversation transcript (JSONL format).
Generate a concise handover document for the next session.

Output ONLY the markdown — no code fences, no preamble.
Use this exact structure (omit empty sections except "What Was Done" and "Next Steps"):

## What Was Done
- (completed work items)

## What Worked and What Didn't
- (successes, bugs, how they were fixed)

## Key Decisions
- (decisions and rationale)

## Lessons Learned & Gotchas
- (pitfalls, workarounds)

## Next Steps
- [ ] (actionable items with enough context to execute)

## Important Files
- `path` — (why it matters)
PROMPT_EOF

BODY=$(cat "$TRANSCRIPT_PATH" | claude -p "$PROMPT" --model haiku 2>/dev/null) || exit 0

mkdir -p "$PROJECT_DIR/.claude"
cat > "$PROJECT_DIR/.claude/HANDOVER-${FILESUFFIX}.md" <<EOF
# Handover

> Generated: ${TIMESTAMP}
> Branch: ${BRANCH}
> Project: ${PROJECT_DIR}

${BODY}
EOF

exit 0
