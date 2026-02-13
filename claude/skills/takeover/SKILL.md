---
name: takeover
description: Resume work from a previous session by reading the handover document. Use at the start of a new session to pick up where the last session left off.
allowed-tools:
  - Read
  - Glob
  - Bash(rm *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git diff *)
  - AskUserQuestion
---

# Takeover Skill

Read the handover document from a previous session, present context, and prepare to continue work.

---

## Workflow

| Step | Action                  | Completion Criteria                                      |
| ---- | ----------------------- | -------------------------------------------------------- |
| 1    | Find handover files     | Available `.claude/HANDOVER-*.md` files discovered       |
| 2    | Gather current git state| Branch, uncommitted changes, recent commits checked      |
| 3    | Present context summary | Handover content displayed with current state comparison |
| 4    | Confirm and clean up    | User confirms, selected handover file deleted            |

---

## Step 1. Find Handover Files

Use the Glob tool to search for `.claude/HANDOVER-*.md`.

- **No files found** → display the following message and exit:

```
No handover files found.

To create one, run /handover in a session before closing it.
```

- **Exactly one file found** → read it directly and proceed to Step 2.

- **Multiple files found** → call `AskUserQuestion` to let the user choose:
  - **question**: `"Multiple handover files found. Which one do you want to resume from?"`
  - **header**: `"Handover"`
  - **options**: One option per file, with:
    - `label`: the filename (e.g. `HANDOVER-20260213-1430.md`)
    - `description`: the date/time from the filename
  - After the user selects, read that file and proceed to Step 2.

---

## Step 2. Gather Current Git State

Run the following commands to compare against the handover state:

```bash
git branch --show-current
git log --oneline -5
git status --short
git diff --stat
```

---

## Step 3. Present Context Summary

Display the handover content to the user in a clear format:

1. Show the handover metadata (when it was generated, which branch)
2. Note any differences between the handover state and the current state:
   - Branch changed since handover?
   - New commits since handover?
   - Uncommitted changes present?
3. Show the "What Was Done" section
4. Show the "Next Steps" section with actionable items highlighted

---

## Step 4. Confirm and Clean Up

Call the `AskUserQuestion` tool with the following parameters:

- **question**: `"Ready to continue with these next steps?"`
- **header**: `"Takeover"`
- **options** (exactly 2):
  - `{ "label": "Continue", "description": "Delete handover file and start working on next steps" }`
  - `{ "label": "Keep file", "description": "Proceed but keep the handover file for reference" }`

### Branching Logic

- User selects **"Continue"** → Delete only the selected handover file with `rm .claude/HANDOVER-YYYYMMDD-HHmm.md`, then begin working on the first next step
- User selects **"Keep file"** → Leave the file in place, then begin working on the first next step
- User enters custom text via **"Other"** → Follow the user's instructions
