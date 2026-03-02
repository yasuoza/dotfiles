---
name: cross-review
description: Run code reviews in parallel using Claude Opus and GitHub Copilot (codex), then produce a unified report. Use when the user requests a cross-review, xreview, multi-LLM review, or wants diverse perspectives on code changes. Accepts optional PR number or file paths as arguments.
---

# Cross Review

Run two independent code reviews in parallel and merge results into a unified report.

## Arguments

| Argument   | Required | Description                                        |
| ---------- | -------- | -------------------------------------------------- |
| PR number  | no       | Pull request number (e.g. `#42`) via `gh pr diff`  |
| File paths | no       | Scope review to specific files                     |

No arguments: review current uncommitted diff (fallback to last commit if clean).

## Workflow

### Step 1: Get the diff

- PR number given: `gh pr diff <number>`
- File paths given: `git diff HEAD -- <paths>`
- Otherwise: `git diff HEAD` (if empty, `git diff HEAD~1`)

If no diff found, ask the user. Save diff to a temp file for both reviewers.

### Step 2: Detect follow-up

Check conversation history for prior cross-review in this session.

- **First review**: No prior context.
- **Follow-up**: Retrieve the previous `agent_id` (Opus) and `COPILOT_SESSION_ID` (Copilot) from the conversation.

### Step 3: Launch parallel reviews

Both reviews MUST be launched in a single message with `run_in_background: true`.

**Review A — Claude Opus:**

| Parameter     | First review    | Follow-up                    |
| ------------- | --------------- | ---------------------------- |
| subagent_type | `code-reviewer` | `code-reviewer`              |
| model         | `opus`          | `opus`                       |
| resume        | —               | previous agent_id            |

Prompt: include full diff, request review of correctness, security, performance, maintainability with file:line fix suggestions. For follow-ups, include only the new diff and ask to note resolved/new issues.

**Review B — GitHub Copilot codex:**

Write a review prompt to `/tmp/copilot-review-prompt.txt` (include the diff and review instructions), then run via shared script:

```bash
# First review
bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-review-prompt.txt

# Follow-up
bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-review-prompt.txt --resume <session_id>
```

Add `--lang <language>` if the codebase uses a non-English language for comments.

Extract `COPILOT_SESSION_ID=...` from the last line of output.

After launching both, inform the user that reviews are running. **Always include `agent_id` and `COPILOT_SESSION_ID` in the response message** so they survive context compaction.

### Step 4: Merge and report

Wait for both results. Read [references/report-format.md](references/report-format.md) for the merge strategy and report template, then produce the unified report.
