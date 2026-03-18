---
name: handover
description: Save current session context to a handover document for the next Claude session. Use only when the user explicitly asks to save a handover, create a shift-change report, or says "/handover".
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash(git diff *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git branch *)
  - Bash(git stash *)
  - Bash(date *)
---

# Handover Skill

Analyze the current session and git state, then generate a structured handover document with both human-readable markdown and machine-parseable JSON for the next Claude session.

## Arguments

This skill takes no arguments. It reads all context from the current conversation history and git state automatically.

---

## Workflow

| Step | Action                | Completion Criteria                                                        |
| ---- | --------------------- | -------------------------------------------------------------------------- |
| 1    | Gather git context    | Branch, commits, status, diff, modified files, stash list collected        |
| 2    | Analyze session       | Completed items, failed approaches, decisions, open questions extracted    |
| 3    | Generate handover doc | All markdown sections and JSON block populated                            |
| 4    | Write file            | `.claude/HANDOVER-YYYYMMDD-HHmm.md` written with actual timestamp         |
| 5    | Display confirmation  | File path and summary shown to user                                        |

---

## Step 1. Gather Git Context

Run each command as a separate Bash call in parallel:

1. `git branch --show-current`
2. `git log --oneline -10`
3. `git status --short`
4. `git diff --stat`
5. `git diff --name-only` (for the modified files list in JSON)
6. `git stash list`

---

## Step 2. Analyze Session

Review the full conversation history and identify:

- **Completed work** — what tasks were finished
- **In-progress work** — what was started but not finished
- **Key decisions** — architectural or implementation choices and their rationale
- **Approaches tried and failed** — what was attempted, what went wrong, and why it didn't work. This is critical: the next session must not repeat dead ends.
- **Problems and fixes** — bugs encountered and how they were resolved
- **Gotchas** — unexpected behaviors or workarounds discovered
- **Failing tests** — any test failures from the session, with error messages
- **Open questions** — unresolved decisions, things to investigate, or questions for the user

---

## Step 3. Generate Handover Document

Produce a markdown document following this exact structure:

```markdown
# Handover

> Generated: {YYYY-MM-DD HH:MM}
> Branch: {current branch}
> Project: {project root path}

## What Was Done

- {completed work items, be specific}

## What Worked and What Didn't

- {successes, bugs encountered, how they were fixed}

## Approaches Tried and Failed

- **{approach}**: {why it failed / what went wrong}

## Key Decisions

- {architectural/implementation decisions and rationale}

## Lessons Learned & Gotchas

- {pitfalls, unexpected behaviors, workarounds}

## Next Steps (Priority Order)

1. [ ] {highest priority — critical/blocking items first}
2. [ ] {next priority item}
3. [ ] {lower priority items}

## Open Questions

- {unresolved decisions, things to investigate}

## Important Files

- `path/to/file` — {why it matters}

<!-- HANDOVER_DATA
{structured JSON — see specification below}
-->
```

### JSON Block Specification

The `<!-- HANDOVER_DATA ... -->` block must contain valid JSON with ALL of these fields (use empty arrays `[]` or `null` when a field has no data — never omit fields):

```json
{
  "version": 2,
  "generated_at": "YYYY-MM-DDTHH:MM:SS",
  "current_branch": "branch-name",
  "modified_files": ["path/to/file1", "path/to/file2"],
  "failing_tests": [
    {
      "test": "test name or file",
      "error": "error message summary",
      "command": "test command used"
    }
  ],
  "approaches_tried_and_failed": [
    {
      "approach": "what was tried",
      "reason": "why it failed"
    }
  ],
  "next_steps": [
    {
      "priority": 1,
      "task": "description",
      "context": "additional context needed to execute"
    }
  ],
  "open_questions": ["question 1", "question 2"],
  "important_files": [
    {
      "path": "path/to/file",
      "reason": "why it matters"
    }
  ],
  "git_state": {
    "last_commit": "hash message",
    "uncommitted_changes": true,
    "stashed_changes": false
  }
}
```

### Guidelines

- Be concise but include enough context for a fresh session to understand the work
- Each "Next Steps" item must be independently actionable with sufficient context
- `next_steps` must be sorted by priority (1 = highest)
- `failing_tests` should include actual error message excerpts, not just "test failed"
- `approaches_tried_and_failed` is critical — it prevents the next session from repeating dead ends
- `important_files` should list files central to the current task, not every file touched
- Omit any markdown section that has no meaningful content (except "What Was Done" and "Next Steps" which are always required)
- The JSON block must always be complete with all fields

---

## Step 4. Write File

Get the current timestamp with `date '+%Y%m%d-%H%M'` and write the generated document to `.claude/HANDOVER-YYYYMMDD-HHmm.md` (using the actual timestamp), creating a unique file per session.

---

## Step 5. Display Confirmation

Show the user:

```
Handover saved to .claude/HANDOVER-YYYYMMDD-HHmm.md

Summary:
- {1-2 line summary of what was captured}
- {N} next steps prioritized, {N} failed approaches documented
- Next session: run /takeover to pick up where you left off
```
