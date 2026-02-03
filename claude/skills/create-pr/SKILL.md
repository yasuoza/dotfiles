---
name: create-pr
description: Create GitHub Pull Requests with auto-generated content based on diff and PR template.
argument-hint: "<base-branch> [--draft]"
context: fork
allowed-tools:
  - Read
  - Bash(git symbolic-ref *)
---

# Create Pull Request Skill

This skill creates GitHub Pull Requests targeting a specified branch.

## Prerequisites

- Git is installed
- GitHub CLI is installed and authenticated
- The repository is a GitHub repository (not GitLab, Bitbucket, etc.)
- The repository is cloned locally
- The skill is executed from the repository root directory

## Argument Interpretation

- `<base-branch>`: The target branch for merging the PR (automatically detects default branch if omitted)
- `--draft`: When this flag is present, creates the PR as a draft

Examples:

- `/create-pr main` → Regular PR to the main branch
- `/create-pr main --draft` → Draft PR to the main branch
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
| 6    | Wait for user confirmation           | User has responded with "OK"              |
| 7    | Draft confirmation (conditional)     | Draft status is determined                |
| 8    | PR creation                          | `gh pr create` succeeded                  |
| 9    | Temporary file deletion              | `.tmp/pr_draft.md` is deleted             |
| 10   | Display results                      | PR URL is displayed to user               |

---

## Step 1. Parameter Validation

Parse the arguments:

1. Check for the presence of `--draft` flag → Store in `isDraft` variable
2. Retrieve the base branch name (from arguments, or detect the default branch)

Default branch detection:

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

## Step 6. Wait for User Confirmation

Display the following message and wait for user response:

```
The PR content has been saved to `.tmp/pr_draft.md` and opened in VS Code.
Once you have finished editing, save the file and type "OK".
```

**Important**: Do not proceed to the next step until the user responds with "OK".

---

## Step 7. Draft Confirmation (Conditional)

**Condition**: Execute only if `--draft` flag was not specified in Step 1

Display the following message and wait for user response:

```
Would you like to create this PR as a draft?
- "draft" or "yes" → Create as draft PR
- "publish" or "no" → Create as regular PR
```

**Important**: Do not proceed to the next step until the user responds.

**Branching Logic**:

- User responds with "draft", "yes", "y", "Y", "YES" → Add `--draft` flag
- User responds with "publish", "no", "n", "N", "NO" → No `--draft` flag

---

## Step 8. PR Creation

Read the latest content from the temporary file and create the PR.

**CRITICAL: The `-a @me` flag is MANDATORY. NEVER omit it.**

The command MUST follow this exact structure:

```bash
gh pr create -a @me --title "<title>" --body-file .tmp/pr_draft.md
```

If draft, append `--draft`:

```bash
gh pr create -a @me --title "<title>" --body-file .tmp/pr_draft.md --draft
```

- `-a @me` — Self-assignment. **NEVER omit this flag.**
- `<title>` — Concise, Conventional Commits format. Determine the language by inspecting the recent `git log` messages from Step 2.
- `--draft` — Added based on Step 1 or Step 7 result

**Japanese Title Rule**: When writing the title in Japanese, ALWAYS use past tense (完了形) for the description part. Use "〜した" instead of "〜する".

| Good (past tense)                              | Bad (present tense)                            |
| ----------------------------------------------- | ----------------------------------------------- |
| `fix: ログインバリデーションを修正した`          | `fix: ログインバリデーションを修正する`          |
| `feat: ユーザー検索機能を追加した`               | `feat: ユーザー検索機能を追加する`               |
| `refactor: 認証ロジックをリファクタリングした`   | `refactor: 認証ロジックをリファクタリングする`   |

---

## Step 9. Temporary File Deletion

**Execute only if PR creation succeeded**:

```bash
rm .tmp/pr_draft.md
```

Deletion verification:

```bash
ls .tmp/pr_draft.md 2>/dev/null && echo "ERROR: File still exists" || echo "OK: Deletion complete"
```

**If PR creation failed**: Do not delete the temporary file, and inform the user "The temporary file has been preserved."

---

## Step 10. Display Results

On successful PR creation:

```
Pull Request created: [PR URL]
Temporary file `.tmp/pr_draft.md` has been deleted.
```

---

## Pre-Completion Checklist

Before completing the process, verify the following:

1. Has the draft status been determined? (from arguments or user response)
2. **Was `-a @me` included in the `gh pr create` command?**
3. If PR creation succeeded, has `.tmp/pr_draft.md` been deleted?
4. Has the deletion been reported to the user?
5. Has the PR URL been displayed to the user?

---

## Error Handling

| Error                        | Action                              |
| ---------------------------- | ----------------------------------- |
| Git command failure          | Display error message and abort     |
| GitHub CLI not authenticated | Prompt user to run `gh auth login`  |
| PR template not found        | Generate basic PR content structure |
| PR creation failure          | Preserve temporary file             |
| PR creation success          | Delete temporary file               |
| `-a @me` missing             | NEVER proceed without `-a @me`      |
