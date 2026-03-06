---
name: codex-review
description: Delegate code review to GitHub Copilot (codex) CLI for a second opinion. Use when the user asks for a codex review, says "codex-review", "use codex to review", or wants an external reviewer's perspective on diffs, PRs, or staged changes. Not for implementation -- only review.
allowed-tools:
  - Bash(cat *)
---

# Codex Review

Delegate code review to the `copilot` CLI agent. Each invocation starts a fresh read-only session (write and shell tools denied).

## Workflow

1. **Gather context**: read relevant diffs and files. Include actual code -- copilot cannot explore on its own.
2. **Pipe prompt to the wrapper script**: use a heredoc to pipe the prompt via stdin. For prompt templates, see [references/examples.md](references/examples.md).
3. **Return raw output**: never edit, summarize, or reformat.

## Execution

Pipe the prompt via heredoc. Add `--lang Japanese` for non-English codebases.

```bash
cat <<'EOF' | bash <skill_path>/scripts/run_copilot.sh
Review the following changes for ...

<diff>
...
</diff>
EOF
```

## Key Rules

- Always execute -- delegation is the core purpose.
- Never edit copilot output -- return it raw.
- Review only. For implementation, use Claude Code directly.
