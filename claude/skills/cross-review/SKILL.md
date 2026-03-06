---
name: cross-review
description: Run code reviews in parallel using Claude Opus and GitHub Copilot (codex), then produce a unified report. Use when the user requests a cross-review, xreview, multi-LLM review, or wants diverse perspectives on code changes. Accepts optional PR number or file paths as arguments.
allowed-tools:
  - Agent
  - Bash(cat *)
  - Bash(gh pr diff *)
  - Bash(git diff *)
  - Read
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

If no diff found, ask the user.

### Step 2: Launch parallel reviews

Both reviews MUST be launched in a single message with `run_in_background: true`.

**Review A -- Claude Opus:**

Launch a `code-reviewer` subagent with `model: opus`. Include full diff, request review of correctness, security, performance, maintainability with file:line fix suggestions.

**Review B -- GitHub Copilot codex:**

Pipe a review prompt via heredoc to the bundled script. Add `--lang <language>` for non-English codebases.

```bash
cat <<'EOF' | bash <skill_path>/scripts/run_copilot.sh
...review prompt with diff...
EOF
```

After launching both, inform the user that reviews are running.

### Step 3: Merge and report

Wait for both results. If one reviewer fails (timeout, crash, empty output), produce the report from the successful reviewer alone and note which reviewer failed and why. If both fail, report the errors to the user.

Read [references/report-format.md](references/report-format.md) for the merge strategy and report template, then produce the unified report.
