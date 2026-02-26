---
name: create-pr
description: "Create GitHub Pull Requests with auto-generated content based on diff and PR template. Use when the user asks to create a PR, open a pull request, or submit changes for review."
argument-hint: "<base-branch> [--draft]"
allowed-tools:
  - Read
  - AskUserQuestion
  - Bash(git symbolic-ref *)
  - Bash(git branch --show-current)
  - Bash(git diff *)
  - Bash(git log *)
  - Bash(gh pr create *)
  - Bash(mkdir *)
  - Bash(rm *)
  - Bash(ls *)
  - Bash(code *)
---

# Create Pull Request Skill

Create a GitHub PR targeting a specified branch with auto-generated content from diff and PR template.

## Arguments

| Argument | Required | Description |
| --- | --- | --- |
| `<base-branch>` | No | Target branch for the PR. Auto-detects default branch if omitted. |
| `--draft` | No | Creates the PR as a draft. |

Examples: `/create-pr main`, `/create-pr main --draft`, `/create-pr --draft`

## Prerequisites

- Git and GitHub CLI (`gh`) installed and authenticated
- Repository is a GitHub repo cloned locally
- Executed from the repository root directory

## Processing Flow

| Step | Process | Completion Criteria |
| --- | --- | --- |
| 1 | Parameter validation | Base branch and draft flag determined |
| 2 | Diff retrieval | git diff and git log results obtained |
| 3 | PR template loading | Template content retrieved |
| 4 | PR content generation | PR body generated |
| 5 | Save temp file + open VS Code | File created and VS Code launched |
| 6 | Confirm with user | User confirmed via AskUserQuestion |
| 7 | PR creation | `gh pr create` succeeded |
| 8 | Cleanup + display results | Temp file handled, PR URL displayed |

---

## Step 1. Parameter Validation

1. Check for `--draft` flag -> store as `isDraft`
2. Get base branch from arguments, or detect default: `git symbolic-ref refs/remotes/origin/HEAD --short | sed 's|origin/||'`

## Step 2. Diff Retrieval

```bash
git branch --show-current
git diff [base-branch]...HEAD
git diff --name-status [base-branch]...HEAD
git log [base-branch]...HEAD --oneline
```

## Step 3. PR Template Loading

Read `.github/PULL_REQUEST_TEMPLATE.md`. If not found, generate a basic PR content structure.

## Step 4. PR Content Generation

Generate PR content based on the diff and template.

## Step 5. Save Temporary File + Launch VS Code

```bash
mkdir -p .tmp
```

Save PR content to `.tmp/pr_draft.md`, then open it:

```bash
code .tmp/pr_draft.md
```

## Step 6. Confirm with User

Call `AskUserQuestion` with:
- **question**: `"PR content has been saved to .tmp/pr_draft.md and opened in VS Code.\nEdit in VS Code if needed, then confirm."`
- **header**: `"Create PR"`

**Options** depend on `isDraft`:

- If `isDraft` is true: `"OK"` (create draft) | `"Re-edit"` (reopen VS Code, loop)
- If `isDraft` is false: `"Draft"` (create as draft) | `"Publish"` (create as regular PR) | `"Re-edit"` (reopen VS Code, loop)

When user selects **"Re-edit"**, run `code .tmp/pr_draft.md` and call `AskUserQuestion` again.

## Step 7. PR Creation

Re-read `.tmp/pr_draft.md` to pick up user edits, then create the PR.

Always include `-a @me` (team convention for self-assignment):

```bash
gh pr create -a @me --title "<title>" --body-file .tmp/pr_draft.md [--draft]
```

**Title format**: Concise Conventional Commits format. Match the language of recent `git log` messages from Step 2.

**Japanese title rule**: Always use past tense (完了形) -- e.g. "〜した" not "〜する". Example: `fix: ログインバリデーションを修正した`

## Step 8. Cleanup + Display Results

**On success**: Delete temp file, verify deletion, display PR URL.

```bash
rm .tmp/pr_draft.md
ls .tmp/pr_draft.md 2>/dev/null && echo "ERROR: File still exists" || echo "OK: Deletion complete"
```

**On failure**: Preserve `.tmp/pr_draft.md` and inform user.

---

## Error Handling

| Error | Action |
| --- | --- |
| Git command failure | Display error message and abort |
| GitHub CLI not authenticated | Prompt user to run `gh auth login` |
| PR template not found | Generate basic PR content structure |
| PR creation failure | Preserve temporary file |
