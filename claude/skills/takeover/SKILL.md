---
name: takeover
description: Load context from a previous session's handover document and present it to the user. This is a context-loading skill — present the information and let the user decide what to do next.
allowed-tools:
  - Read
  - Glob
  - Bash(rm *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git branch *)
  - AskUserQuestion
---

# Takeover

Load and present context from a previous session's handover document. The user will decide what to work on after reviewing the context, so this skill only reads and displays information -- it ends after presenting the summary and cleaning up the handover file.

---

## Workflow

| Step | Action                   | Completion Criteria                                      |
| ---- | ------------------------ | -------------------------------------------------------- |
| 1    | Find handover files      | Available `.claude/HANDOVER-*.md` files discovered       |
| 2    | Gather current git state | Branch, uncommitted changes, recent commits checked      |
| 3    | Present context summary  | Handover content displayed with current state comparison |
| 4    | Clean up and finish      | User chooses whether to delete the handover file         |

---

## Step 1. Find Handover Files

Use the Glob tool to search for `.claude/HANDOVER-*.md`.

- **No files found** → display the following message and finish:

```
No handover files found.

To create one, run /handover in a session before closing it.
```

- **Exactly one file found** → read it and proceed to Step 2.

- **Multiple files found** → read the first few lines of each file to extract a summary, then call `AskUserQuestion` to let the user choose:
  - **question**: `"Multiple handover files found. Which one do you want to resume from?"`
  - **header**: `"Handover"`
  - **options**: One option per file, with:
    - `label`: the filename (e.g. `HANDOVER-20260213-1430.md`)
    - `description`: first bullet from "What Was Done" section (truncated to fit)
  - After the user selects, read the full file and proceed to Step 2.

---

## Step 2. Gather Current Git State

Run each command as a separate Bash call in parallel:

1. `git branch --show-current`
2. `git log --oneline -5`
3. `git status --short`
4. `git diff --stat`

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

After presenting, proceed directly to Step 4. The user will decide what to work on after the skill finishes.

---

## Step 4. Clean Up and Finish

Call `AskUserQuestion` with:

- **question**: `"Delete the handover file?"`
- **header**: `"Takeover"`
- **options** (exactly 2):
  - `{ "label": "Delete", "description": "Remove the handover file now that context is loaded" }`
  - `{ "label": "Keep", "description": "Keep the handover file for reference" }`

- User selects **"Delete"** → delete the selected handover file with `rm .claude/HANDOVER-YYYYMMDD-HHmm.md`, then finish
- User selects **"Keep"** → leave the file in place, then finish
- User enters custom text via **"Other"** → follow the user's instructions

The skill is complete after this step.
