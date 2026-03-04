---
name: takeover
description: Load context from a previous session's handover document and present it to the user. This is a context-loading skill — present the information and let the user decide what to do next.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(rm *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git diff *)
  - Bash(git branch *)
  - Bash(git checkout *)
  - Bash(git stash *)
  - AskUserQuestion
---

# Takeover

Load and present context from a previous session's handover document. Parses the structured JSON section to restore context, re-read important files, and present a prioritized checklist of next steps. Falls back to git state reconstruction if no handover file exists.

---

## Workflow

| Step | Action                   | Completion Criteria                                      |
| ---- | ------------------------ | -------------------------------------------------------- |
| 1    | Find handover files      | `.claude/HANDOVER-*.md` files discovered                 |
| 2    | Parse handover data      | JSON block extracted and parsed, or fallback triggered   |
| 3    | Restore git state        | Branch verified, discrepancies identified                |
| 4    | Re-read important files  | Key files loaded into context                            |
| 5    | Present checklist        | Prioritized next steps and warnings displayed            |
| 6    | Clean up and finish      | User chooses whether to delete the handover file         |

---

## Step 1. Find Handover Files

Use the Glob tool to search for `.claude/HANDOVER-*.md`.

- **No files found** → proceed to **Step 2 Fallback Mode**
- **Exactly one file found** → read it and proceed to **Step 2 Normal Mode**
- **Multiple files found** → read the first few lines of each file to extract a summary, then call `AskUserQuestion` to let the user choose:
  - **question**: `"Multiple handover files found. Which one do you want to resume from?"`
  - **header**: `"Handover"`
  - **options**: One option per file, with:
    - `label`: the filename (e.g. `HANDOVER-20260213-1430.md`)
    - `description`: first bullet from "What Was Done" section (truncated to fit)
  - After the user selects, read the full file and proceed to **Step 2 Normal Mode**.

---

## Step 2. Parse Handover Data

### Normal Mode (handover file exists)

1. Read the full handover file content
2. Extract the JSON block: find content between `<!-- HANDOVER_DATA` and `-->` markers
3. Parse the JSON to get structured data fields:
   - `current_branch`, `modified_files`, `failing_tests`
   - `approaches_tried_and_failed`, `next_steps`, `open_questions`
   - `important_files`, `git_state`
4. Also note the markdown sections for human-readable context

If the JSON block is missing or malformed (e.g. v1 handover format), fall back to reading the markdown sections only. Extract what you can: branch from the header, next steps from the checklist, important files from the section.

### Fallback Mode (no handover file)

When no handover file exists, reconstruct context from git state:

1. Run these commands in parallel:
   - `git branch --show-current`
   - `git log --oneline -20` (extra history to compensate)
   - `git status --short`
   - `git diff --stat`
   - `git diff --name-only HEAD~5` (recently changed files)
   - `git stash list`
2. Identify the most recently modified source files from `git diff --name-only HEAD~5`
3. Read those files (up to 10) to load them into context
4. Construct a synthetic context from git data
5. Skip directly to **Step 5** with the reconstructed data, clearly marking it as a **fallback reconstruction**

---

## Step 3. Restore Git State

Compare the handover's recorded state with the current state.

1. Run in parallel:
   - `git branch --show-current`
   - `git log --oneline -5`
   - `git status --short`
   - `git diff --stat`
   - `git stash list`

2. Check for discrepancies:

   **Branch mismatch**: If the current branch differs from the handover's `current_branch`, ask:
   - `AskUserQuestion` with question: `"You're on '{current}' but the handover was on '{expected}'. Switch branches?"`
   - header: `"Branch"`
   - options: `"Switch to {expected}"`, `"Stay on {current}"`
   - If switch selected: `git checkout {expected}`

   **New commits since handover**: Note any commits made after the handover's `generated_at` timestamp.

   **Uncommitted changes**: Note if there are uncommitted changes present now.

   **Stashed changes**: If the handover's `git_state.stashed_changes` is true, check `git stash list` and mention it.

---

## Step 4. Re-read Important Files

From the parsed JSON `important_files` array:

1. Read each file listed (up to 10 files to avoid context bloat)
2. If a file no longer exists, note it as a warning
3. This loads key files into the current session's context for immediate work

If working from a v1 handover (no JSON), extract file paths from the "Important Files" markdown section instead.

---

## Step 5. Present Checklist

Display a structured summary to the user.

### Normal Mode Output

```
## Session Takeover

**Previous session**: {generated_at}
**Branch**: {current_branch} {✓ matches / ⚠ switched / ⚠ mismatch}
**Modified files**: {count from modified_files array}

### ⚠ Warnings
- {branch mismatch, new commits, missing files, uncommitted changes}
(omit section if no warnings)

### Failed Approaches — Do Not Retry
- ✗ {approach} — {reason}
(omit section if empty)

### Failing Tests
- ✗ {test} (`{command}`): {error}
(omit section if empty)

### Next Steps
- [ ] 🔴 P1: {task} — {context}
- [ ] 🟡 P2: {task} — {context}
- [ ] 🟢 P3: {task} — {context}

### Open Questions
- ❓ {question}
(omit section if empty)

### Files Loaded into Context
- `{path}` — {reason}
```

Priority indicators:
- 🔴 Priority 1 — critical or blocking
- 🟡 Priority 2 — important
- 🟢 Priority 3+ — nice to have

### Fallback Mode Output

```
## Session Takeover (Reconstructed from Git)

⚠ No handover file found. Context reconstructed from git state.

**Branch**: {branch}
**Recent commits**:
- {last 5 commit summaries}

**Uncommitted changes**: {yes/no + summary}

### Recently Modified Files (Loaded)
- `{file}` — modified in recent commits

### Suggested Next Steps
Based on recent git activity:
- [ ] {inferred tasks from commit messages and file changes}

> Tip: Use /handover before ending sessions to preserve full context including
> failed approaches, open questions, and prioritized next steps.
```

---

## Step 6. Clean Up and Finish

Skip this step entirely if in fallback mode.

Call `AskUserQuestion` with:

- **question**: `"Delete the handover file?"`
- **header**: `"Takeover"`
- **options** (exactly 2):
  - `{ "label": "Delete", "description": "Remove the handover file now that context is loaded" }`
  - `{ "label": "Keep", "description": "Keep the handover file for reference" }`

- User selects **"Delete"** → `rm .claude/HANDOVER-{filename}.md`, then finish
- User selects **"Keep"** → leave the file in place, then finish
- User enters custom text via **"Other"** → follow the user's instructions

The skill is complete after this step.
