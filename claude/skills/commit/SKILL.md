---
name: commit
description: Generate a Conventional Commits format commit message from staged changes and execute the commit after user confirmation. Use when changes have been staged with git add.
argument-hint: "[--amend]"
allowed-tools:
  - Read
  - Bash(git diff --cached *)
  - Bash(git commit *)
  - Bash(git log *)
  - AskUserQuestion
---

# Commit Skill

Analyze staged changes, generate a Conventional Commits format commit message, and execute the commit.

---

## Workflow

| Step | Action                  | Completion Criteria                          |
| ---- | ----------------------- | -------------------------------------------- |
| 1    | Check staging           | Staged changes exist                         |
| 2    | Retrieve diff           | git diff --cached output retrieved           |
| 3    | Generate commit message | Message drafted                              |
| 4    | Confirm with user       | User confirmed via AskUserQuestion tool call |
| 5    | Execute commit          | git commit succeeded                         |
| 6    | Display result          | Commit hash displayed                        |

---

## Step 1. Check Staging

```bash
git diff --cached --stat
```

If no staged changes exist:

- Display "No staged changes found. Please stage files with `git add`." and exit

---

## Step 2. Retrieve Diff

```bash
git diff --cached
git diff --cached --name-status
```

---

## Step 3. Generate Commit Message

### Conventional Commits Format

```
<type>(<scope>): <description>

[optional body]
```

### Type (Required)

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code (whitespace, formatting, etc.)
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding or modifying tests
- `chore`: Changes to build process or auxiliary tools

### Scope (Recommended)

Include whenever possible:

- Directory name: `feat(api)`, `fix(ui)`
- Feature name: `feat(auth)`, `fix(payment)`
- File type: `docs(readme)`, `test(unit)`

### Description (Required)

- Write in imperative mood (e.g., "add", "fix", "update")
- Keep under 50 characters as a guideline
- Do not end with a period
- Use recent commit language (Based on git logs)

---

## Step 4. Confirm with User

Call the `AskUserQuestion` tool with the following parameters:

- **question**: `"Commit with this message?\n\n<generated commit message>"`
- **header**: `"Commit"`
- **options** (exactly 2):
  - `{ "label": "OK", "description": "Proceed with the generated message" }`
  - `{ "label": "Modify", "description": "Enter a revised message" }`

### Branching Logic

- User selects **"OK"** → Use the generated message as-is
- User selects **"Modify"** or enters custom text via **"Other"** → Use the user's input as the commit message

---

## Step 5. Execute Commit

Execute the commit with the confirmed message:

```bash
git commit -m "<commit message>"
```

For multi-line messages, use HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
<commit message>
EOF
)"
```

If the `--amend` flag is specified:

```bash
git commit --amend -m "<commit message>"
```

---

## Step 6. Display Result

On successful commit:

```
Committed: [short commit hash]
```

---

## Error Handling

| Error             | Action                   |
| ----------------- | ------------------------ |
| No staged changes | Display message and exit |
| Commit failure    | Display error details    |
