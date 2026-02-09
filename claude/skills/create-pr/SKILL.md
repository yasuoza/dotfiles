---
name: create-pr
description: Create GitHub Pull Requests with auto-generated content based on diff and PR template.
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

This skill creates GitHub Pull Requests targeting a specified branch.

## Prerequisites

- Git and GitHub CLI (`gh`) are installed and authenticated
- The repository is a GitHub repository cloned locally
- The skill is executed from the repository root directory

## Argument Interpretation

- `<base-branch>`: The target branch for merging the PR (auto-detects default branch if omitted)
- `--draft`: Creates the PR as a draft

Examples:

- `/create-pr main` → Regular PR to main
- `/create-pr main --draft` → Draft PR to main
- `/create-pr --draft` → Draft PR to the default branch

---

## Processing Flow

| Step | Process                              | Completion Criteria                       |
| ---- | ------------------------------------ | ----------------------------------------- |
| 1    | Parameter validation                 | Base branch and draft flag are determined |
| 2    | Diff retrieval                       | git diff and git log results are obtained |
| 3    | PR template loading                  | Template content is retrieved             |
| 4    | PR content generation                | PR body is generated                      |
| 5    | Save temporary file + Launch VS Code | File created and VS Code launched         |
| 6    | Confirm with user                    | User confirmed via AskUserQuestion        |
| 7    | PR creation                          | `gh pr create` succeeded                  |
| 8    | Temporary file deletion              | `.tmp/pr_draft.md` is deleted             |
| 9    | Display results                      | PR URL is displayed to user               |

---

## Step 1. Parameter Validation

Parse the arguments:

1. Check for `--draft` flag → Store in `isDraft` variable
2. Retrieve the base branch name from arguments, or detect the default branch:

```bash
git symbolic-ref refs/remotes/origin/HEAD --short | sed 's|origin/||'
```

---

## Step 2. Diff Retrieval

```bash
git branch --show-current
git diff [base-branch]...HEAD
git diff --name-status [base-branch]...HEAD
git log [base-branch]...HEAD --oneline
```

---

## Step 3. PR Template Loading

Read `.github/PULL_REQUEST_TEMPLATE.md`. If it does not exist, generate a basic PR content structure.

---

## Step 4. PR Content Generation

Generate PR content based on the diff and template.

---

## Step 5. Save Temporary File + Launch VS Code

```bash
mkdir -p .tmp
```

Save the PR content to `.tmp/pr_draft.md`.

```bash
code .tmp/pr_draft.md
```

---

## Step 6. Confirm with User

Call the `AskUserQuestion` tool with the following parameters:

### When `--draft` was specified in Step 1:

- **question**: `"PR content has been saved to .tmp/pr_draft.md and opened in VS Code.\nEdit in VS Code if needed, then confirm."`
- **header**: `"Create PR"`
- **options** (exactly 2):
  - `{ "label": "OK", "description": "Create the draft PR" }`
  - `{ "label": "Re-edit", "description": "Re-open VS Code and continue editing" }`

### When `--draft` was NOT specified in Step 1:

- **question**: `"PR content has been saved to .tmp/pr_draft.md and opened in VS Code.\nEdit in VS Code if needed, then confirm."`
- **header**: `"Create PR"`
- **options** (exactly 3):
  - `{ "label": "Draft", "description": "Create as draft PR" }`
  - `{ "label": "Publish", "description": "Create as regular PR" }`
  - `{ "label": "Re-edit", "description": "Re-open VS Code and continue editing" }`

### Branching Logic

- User selects **"OK"** or **"Draft"** → Create as draft PR
- User selects **"Publish"** → Create as regular PR
- User selects **"Re-edit"** → Re-open VS Code (`code .tmp/pr_draft.md`) and call `AskUserQuestion` again (loop)

---

## Step 7. PR Creation

Re-read `.tmp/pr_draft.md` to pick up any user edits, then create the PR.

Always include `-a @me` to self-assign the PR (this is a team convention):

```bash
gh pr create -a @me --title "<title>" --body-file .tmp/pr_draft.md
```

If draft, append `--draft`:

```bash
gh pr create -a @me --title "<title>" --body-file .tmp/pr_draft.md --draft
```

**Title format**: Use concise Conventional Commits format. Match the language used in recent `git log` messages from Step 2.

**Japanese title rule**: Use past tense (完了形) — "〜した" not "〜する".

| Good (past tense)                              | Bad (present tense)                            |
| ----------------------------------------------- | ----------------------------------------------- |
| `fix: ログインバリデーションを修正した`          | `fix: ログインバリデーションを修正する`          |
| `feat: ユーザー検索機能を追加した`               | `feat: ユーザー検索機能を追加する`               |
| `refactor: 認証ロジックをリファクタリングした`   | `refactor: 認証ロジックをリファクタリングする`   |

---

## Step 8. Temporary File Deletion

On PR creation success, delete the temporary file and verify:

```bash
rm .tmp/pr_draft.md
ls .tmp/pr_draft.md 2>/dev/null && echo "ERROR: File still exists" || echo "OK: Deletion complete"
```

On PR creation failure, preserve the file and inform the user: "The temporary file has been preserved."

---

## Step 9. Display Results

On successful PR creation:

```
Pull Request created: [PR URL]
Temporary file `.tmp/pr_draft.md` has been deleted.
```

---

## Error Handling

| Error                        | Action                              |
| ---------------------------- | ----------------------------------- |
| Git command failure          | Display error message and abort     |
| GitHub CLI not authenticated | Prompt user to run `gh auth login`  |
| PR template not found        | Generate basic PR content structure |
| PR creation failure          | Preserve temporary file             |
