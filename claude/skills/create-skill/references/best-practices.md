# Skill Creation Best Practices

Practical lessons learned from creating real skills (manual-screenshots, commit, create-pr, etc.).

## Progressive Disclosure Architecture

Skills load in three layers to manage the context window efficiently:

| Layer | When loaded | What to put here |
|-------|-------------|------------------|
| **Description** (frontmatter) | Always in context (~100 tokens) | Trigger words, one-line purpose |
| **SKILL.md body** | On invocation | Workflow, steps, constraints |
| **references/ & templates/** | On demand (via Read) | Detailed patterns, examples, code |

### Rules

- SKILL.md should be **under 100 lines** ideally, **under 500** maximum
- Information lives in **one place only** — SKILL.md or a reference file, not both
- Keep references **one level deep** from SKILL.md (no nested subdirectories)
- For files over 100 lines, include a **table of contents**

## Description Writing

The `description` field is how Claude decides when to activate a skill. It's the most important line.

### Pattern

```
<What it does> + <When to use it / trigger phrases>
```

### Good examples

```yaml
# Specific verbs + explicit triggers
description: Takes manual screenshots via Chrome DevTools MCP with bilingual support. Use when the user asks to capture, retake, or update manual screenshots.

description: Generate a Conventional Commits format commit message from staged changes. Use when changes have been staged with git add.

description: Create GitHub Pull Requests with auto-generated content based on diff and PR template.
```

### Bad examples

```yaml
# Too vague — Claude can't distinguish from general coding
description: Helps with development tasks

# Missing trigger context — Claude doesn't know WHEN to use it
description: Screenshot tool

# Multi-line — breaks the YAML parser
description: >-
  This skill takes screenshots
  and masks sensitive data
```

## allowed-tools Scoping

**Principle of least privilege** — only grant what the skill actually needs.

### Bash glob patterns

| Pattern | Matches |
|---------|---------|
| `Bash(git *)` | Any git command |
| `Bash(git diff *)` | Only git diff |
| `Bash(npm run *)` | npm run scripts |
| `Bash(ls:*)` | ls commands |
| `Bash(mkdir:*)` | mkdir commands |

### Common tool sets by skill type

**Read-only / analysis skills:**
```yaml
allowed-tools:
  - Read
  - Glob
  - Grep
```

**Git workflow skills:**
```yaml
allowed-tools:
  - Read
  - Bash(git *)
  - Bash(gh *)
  - AskUserQuestion
```

**Browser automation skills:**
```yaml
allowed-tools:
  - Read
  - Write
  - mcp__chrome-devtools__navigate_page
  - mcp__chrome-devtools__evaluate_script
  - mcp__chrome-devtools__take_screenshot
  # ... only the MCP tools actually used
```

**File generation skills:**
```yaml
allowed-tools:
  - Read
  - Write
  - Bash(mkdir:*)
  - Bash(ls:*)
```

### Gotcha: Shell operators break matching

`Bash(git status && git diff *)` does NOT work. Shell operators (`&&`, `||`, `;`, `|`, `>`) break wildcard matching. Workaround: list each command pattern separately or use a wrapper script.

## Workflow Body Structure

Use a **table overview** followed by **numbered steps** with clear completion criteria.

### Table overview pattern (from commit skill)

```markdown
| Step | Action              | Completion Criteria                |
| ---- | ------------------- | ---------------------------------- |
| 1    | Check prerequisites | Required state verified            |
| 2    | Gather data         | Input data collected               |
| 3    | Process             | Output generated                   |
| 4    | Confirm             | User confirmed via AskUserQuestion |
| 5    | Execute             | Action completed                   |
| 6    | Report              | Results displayed to user          |
```

### Step detail pattern

```markdown
## Step N. Action Name

Concrete instructions in imperative form.

- Use code blocks for commands
- Use bullet lists for branching logic
- Include error handling where relevant
```

## When to Split into References

Move content to `references/` when:

- Code examples exceed **10 lines**
- A pattern is **reusable across multiple steps**
- Documentation is **domain-specific** (API schemas, protocol details)
- The section would make SKILL.md exceed **100 lines**

Keep in SKILL.md when:

- The instruction is **3-5 lines** and only used once
- It's a **constraint or gotcha** (Key Constraints section)
- It's the **workflow overview** (table + step headers)

## When to Use Templates

Create files in `templates/` when:

- The skill accepts a **configuration file** (YAML manifest, JSON config)
- Users need a **starter file** they copy and customize
- Example data helps **illustrate the expected format**

Template files should have:

- **Inline comments** explaining each section
- **Realistic example values** (not just placeholders)
- A header comment showing **usage** (`# Copy this file and customize...`)

## Common Mistakes to Avoid

1. **Over-engineering** — Don't create references/ for a 30-line skill
2. **Redundant information** — Don't repeat SKILL.md content in references
3. **Missing trigger words** — Description without "Use when..." leaves Claude guessing
4. **Too many allowed-tools** — Grant `Bash(*)` only if truly needed
5. **Auxiliary files** — Don't create README, CHANGELOG, INSTALLATION_GUIDE
6. **Verbose explanations** — Claude is smart; only add context it doesn't already have
