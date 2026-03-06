# Codex Review -- Prompt Template

## Template

```
Review the following changes for correctness, security, performance, and
adherence to project conventions. The project is <project description>.

Changes:
<diff>
actual diff content
</diff>

Key files for context:
<context>
actual code from changed files
</context>

Focus on: <specific focus areas if any>.
```

## Gathering the diff

| Trigger | Command |
|---|---|
| PR number | `gh pr diff <number>` |
| Staged changes | `git diff --cached` |
| Uncommitted changes | `git diff HEAD` |
| Last commit | `git diff HEAD~1` |
