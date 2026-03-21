---
name: loop-review-fix
description: "Run an automated codex-review → auto-fix → re-review loop until no major+ issues remain. Use when the user says 'codex-review loop', 'review loop', 'loop-review-fix', 'keep reviewing and fixing until clean', 'review and fix loop', 'automated review cycle', or any variation of iterating reviews and fixes automatically. NOT for one-shot reviews — use /codex-review for those."
argument-hint: "[review-aspects]"
---

# Review-Fix Loop

Automated cycle: codex review → auto-fix all major+ findings → commit → re-review → repeat until clean.

**Review Aspects (optional):** "$ARGUMENTS"

## Why this runs autonomously

Every fix is committed as a separate round. If the user disagrees with any round's changes, `git revert <hash>` undoes it cleanly. Asking permission for each finding — via AskUserQuestion or inline — defeats the purpose of automation. The cost of reverting one bad fix is low; the cost of interrupting the user 10 times per round is high.

**Do not use AskUserQuestion during the loop.** Fix, commit, move on.

## Inputs

From user or context:
- **Target**: branch, PR number, commit range, or staged changes
- **Base branch**: defaults to `main`
- **Review aspects** (optional): specific areas to focus on (see below)
- **Scope exclusions** (optional): areas to ignore

If the target is not specified, infer from `git branch --show-current` and diff against `main`.

### Review aspects

If `$ARGUMENTS` is provided, focus the review only on those aspects. If empty, review everything.

Available aspects:
- **security** — authentication, authorization, injection, secrets exposure
- **performance** — N+1 queries, unnecessary allocations, blocking calls
- **error-handling** — unhandled errors, silent failures, missing validation
- **logic** — correctness bugs, race conditions, edge cases
- **all** — everything above (default when no arguments given)

Multiple aspects can be combined: `/loop-review-fix security performance`

## The Loop

### Step 1: Gather diff and context

```bash
# Choose based on target
git diff main...HEAD          # branch vs main
gh pr diff <number>           # PR
git diff --cached             # staged
git diff HEAD~1               # last commit
```

Also read the key changed files in full — codex cannot explore on its own, so include actual code.

### Step 2: Run codex review

Pipe the diff and context to the codex review script. The script lives at `<skill_path>/../codex-review/scripts/run_copilot.sh`.

Build the review prompt with the appropriate focus areas based on `$ARGUMENTS`:

```bash
cat <<'REVIEW_EOF' | bash <skill_path>/../codex-review/scripts/run_copilot.sh
Review the following changes. Report ONLY major and critical severity findings.
Do not report minor, stylistic, or "nice to have" suggestions.

${ASPECT_INSTRUCTION}

For each finding, use exactly this format:

## Finding: <title>
- **Severity**: major | critical
- **File**: <filepath>:<line>
- **Issue**: <description>
- **Fix**: <suggested fix>

If there are no major or critical findings, output exactly:
NO_MAJOR_FINDINGS

<changes_summary>
${SUMMARY}
</changes_summary>

<diff>
${DIFF}
</diff>

<context>
${CONTEXT}
</context>

${ROUND_CONTEXT}
REVIEW_EOF
```

Where:
- `${ASPECT_INSTRUCTION}` — if specific aspects were requested, add: `Limit your review to the following aspects: ${aspects}`. If "all" or empty, omit this line.
- `${ROUND_CONTEXT}` (round 2+ only) — findings fixed in previous rounds, and findings intentionally skipped with reasons, so codex doesn't re-raise them.

### Step 3: Check exit

Parse the codex output. If:
- Output contains `NO_MAJOR_FINDINGS`, or
- No `## Finding:` sections exist in the output

→ Zero major+ findings. The loop is done. Jump to the exit report.

### Step 4: Auto-fix all findings

Process each major+ finding from the review output:

**a) User intent conflict (fast check, no user input needed):**
Does this finding directly contradict something the user explicitly stated in this conversation? For example, the user said "eval is intentional here" and codex flags eval usage. If yes → skip silently, add to the skip list with the reason. Include in the next round's `${ROUND_CONTEXT}` so codex has the context and doesn't re-raise it.

**b) Security findings — web search first:**
If the finding concerns a security vulnerability, do a quick web search to verify the risk is real before fixing. If the search clearly debunks the risk → skip with evidence. Otherwise → fix. Either way, don't ask the user — just document what you found.

**c) Everything else — just fix it:**
Read the relevant code, understand the issue, apply the minimal fix. Don't refactor surrounding code or add unrelated improvements.

After fixing all findings for this round:
1. Run any relevant tests or linters to verify the fixes don't break anything
2. Stage all changes
3. Commit: `fix(<scope>): address review findings (round N)` — include a brief list of what was fixed in the commit body

Then go back to Step 1 for the next round.

### Step 5: Safety valve

If the loop exceeds **10 rounds** without reaching zero major+ findings → stop. This likely means:
- Fixes are introducing new major+ issues (oscillation)
- A structural problem needs human judgment
- Codex keeps raising the same major+ finding despite context

Stop and go to the exit report.

## Exit Report

When the loop ends, output:

```
## Review-Fix Loop Complete

**Rounds**: N
**Status**: Clean / Stopped (safety valve) / Stopped (user request)

### Fixed
| Round | Finding              | Commit  |
|-------|----------------------|---------|
| 1     | ...                  | abc1234 |
| 2     | ...                  | def5678 |

### Skipped (user intent conflict)
- <finding>: <reason>

### Skipped (verified non-issue)
- <finding>: <web search evidence>

### Unresolved (safety valve only)
- <finding>: <why it couldn't converge>
```

## Usage Examples

```
/loop-review-fix                    # review all aspects
/loop-review-fix security           # security only
/loop-review-fix security logic     # security and logic
/loop-review-fix performance        # performance only
```

## Key Rules

- **Do not use AskUserQuestion during the loop.** This is the #1 rule. The whole point of this skill is to run uninterrupted.
- **Fix everything that isn't a clear user-intent conflict.** When in doubt, fix it. The user can revert.
- **Web search for security only.** Don't web search for style, logic, or performance findings — just fix them.
- **Major+ only.** Completely ignore minor severity, style suggestions, and "nice to have" improvements.
- **One commit per round.** Not per finding — per round. Keeps git history clean.
- **Include round context.** Each review round must tell codex what was already fixed and what was intentionally skipped, so it doesn't raise the same things again.
