---
name: handover
description: Save current session context to a handover document for the next Claude session. Use at any point to create a shift-change report.
allowed-tools:
  - Read
  - Write
  - Bash(git diff *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git branch *)
  - Bash(date *)
---

# Handover Skill

Analyze the current session and git state, then generate a structured handover document for the next Claude session.

---

## Workflow

| Step | Action                | Completion Criteria                                      |
| ---- | --------------------- | -------------------------------------------------------- |
| 1    | Gather git context    | Current branch, recent commits, uncommitted changes      |
| 2    | Analyze session       | Session work summarized from conversation history        |
| 3    | Generate handover doc | Structured markdown document drafted                     |
| 4    | Write file            | `.claude/HANDOVER-YYYYMMDD-HHmm.md` written successfully |
| 5    | Display confirmation  | File path and summary shown to user                      |

---

## Step 1. Gather Git Context

Run each command as a **separate Bash call in parallel** (do NOT chain with `&&` or `;`):

1. `git branch --show-current`
2. `git log --oneline -10`
3. `git status --short`
4. `git diff --stat`

---

## Step 2. Analyze Session

Review the full conversation history and identify:

- What tasks were worked on
- What was completed vs. left in progress
- Key decisions made and their rationale
- Problems encountered and how they were resolved
- Unexpected behaviors or gotchas discovered

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

## Key Decisions

- {architectural/implementation decisions and rationale}

## Lessons Learned & Gotchas

- {pitfalls, unexpected behaviors, workarounds}

## Next Steps

- [ ] {clear actionable items with enough context to execute}

## Important Files

- `path/to/file` — {why it matters}
```

### Guidelines

- Be concise but include enough context for a fresh session to understand the work
- Each "Next Steps" item should be independently actionable
- "Important Files" should list files central to the current task, not every file touched
- Omit any section that has no meaningful content (except "What Was Done" and "Next Steps" which are always required)

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
- Next session: run /takeover to pick up where you left off
```
