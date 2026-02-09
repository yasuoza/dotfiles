---
name: commit
description: Generate a Conventional Commits format commit message from staged changes and execute the commit after user confirmation. Use when changes have been staged with git add.
argument-hint: "[--amend]"
context: fork
allowed-tools:
  - Bash(git diff --cached *)
  - Bash(git commit *)
---

# Commit Skill

Analyze staged changes, generate a Conventional Commits format commit message, and execute the commit.

---

## Workflow

| Step | Action                              | Completion Criteria                         |
| ---- | ----------------------------------- | ------------------------------------------- |
| 1    | Check staging                       | Staged changes exist                        |
| 2    | Retrieve diff                       | git diff --cached output retrieved          |
| 3    | Generate and present commit message | Message generated and displayed to user     |
| 4    | Wait for user confirmation          | User has entered "OK" or a modified message |
| 5    | Execute commit                      | git commit succeeded                        |
| 6    | Display result                      | Commit hash displayed                       |

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

## Step 3. Generate and Present Commit Message

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

### Display Format for Generated Message

Present the message in the following format:

```
Proposed commit message:

feat(api): add user authentication endpoint

- Implement POST /api/auth/login
- Add JWT token generation

---
Enter "OK" to proceed with this message.
To modify, enter your revised commit message.
```

---

## Step 4. Wait for User Confirmation

**Important**: Do not proceed to the next step until the user responds.

**Branching Logic**:

- User responds with "OK", "ok", "yes", "y", "Y", "YES" → Use the message generated in Step 3
- User enters anything else → Use the entered content as the commit message

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
