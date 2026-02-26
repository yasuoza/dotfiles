# Frontmatter Reference

All available YAML frontmatter fields for SKILL.md.

## Core Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Recommended | Slash-command name. Lowercase, hyphens, max 64 chars. Defaults to directory name. |
| `description` | Recommended | Single-line: what it does + when to use it. Primary trigger mechanism. |
| `argument-hint` | No | Autocomplete hint. Example: `"<file> [--format json]"` |
| `allowed-tools` | No | Tools usable without permission prompts. YAML list or comma-separated. |

## Advanced Fields

| Field | Default | Description |
|-------|---------|-------------|
| `model` | (inherit) | Model override. Example: `"claude-sonnet-4-20250514"` |
| `context` | (none) | Set to `fork` to run in isolated subagent context. |
| `agent` | `general-purpose` | Subagent type when `context: fork`. Options: `general-purpose`, `Explore`, `Plan`, `code-reviewer`. |
| `user-invocable` | `true` | Set `false` to hide from `/` menu (background knowledge only). |
| `disable-model-invocation` | `false` | Set `true` to prevent Claude from auto-loading (user-only trigger). |

## Hooks (Advanced)

Scoped lifecycle hooks for the skill:

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate.sh"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "./scripts/lint.sh"
  Stop:
    - hooks:
        - type: command
          command: "./scripts/cleanup.sh"
```

## Invocation Control

| Config | User invokes | Claude invokes | Description in context |
|--------|-------------|---------------|----------------------|
| (default) | Yes | Yes | Yes |
| `disable-model-invocation: true` | Yes | No | No |
| `user-invocable: false` | No | Yes | Yes |

## String Substitutions

Available in SKILL.md body:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed |
| `$1`, `$2`, ... | Positional arguments (0-based: `$ARGUMENTS[0]`) |
| `${CLAUDE_SESSION_ID}` | Current session ID |

## Dynamic Context

Shell commands run before content is sent to Claude:

```markdown
Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
```
