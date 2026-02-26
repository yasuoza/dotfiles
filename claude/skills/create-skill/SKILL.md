---
name: create-skill
description: Create a new Claude Code skill with proper structure, progressive disclosure architecture, and best practices. Use when the user asks to create, scaffold, or set up a new skill.
argument-hint: "<skill-name> [--scope user|project]"
allowed-tools:
  - Read
  - Write
  - Bash(mkdir:*)
  - Bash(ls:*)
  - AskUserQuestion
---

# Create Skill

Scaffold a new Claude Code skill following the best practices learned from real skill creation experience.

## Arguments

- `$1` — Skill name (lowercase, hyphens). Required.
- `--scope` — `user` (`~/.claude/skills/`) or `project` (`.claude/skills/`). Default: `project`.

---

## Workflow

| Step | Action                    | Completion Criteria                              |
| ---- | ------------------------- | ------------------------------------------------ |
| 1    | Gather requirements       | Skill purpose, tools, triggers are understood    |
| 2    | Determine structure       | Directories and files planned                    |
| 3    | Write SKILL.md            | Frontmatter + body written                       |
| 4    | Write reference files     | Detailed docs in references/ (if needed)         |
| 5    | Write templates           | Example/template files in templates/ (if needed) |
| 6    | Verify                    | Skill appears in `/` menu                        |

---

## Step 1. Gather Requirements

Ask the user (or infer from context):

1. **What does the skill do?** — Core purpose in one sentence
2. **When should it trigger?** — User actions or phrases that should activate it
3. **What tools does it need?** — MCP tools, Bash commands, Read/Write, etc.
4. **Does it need reference files?** — Detailed patterns, API docs, code snippets
5. **Does it need templates?** — Example configs, manifests, or starter files

If the user already described the skill clearly, skip the questions and proceed.

---

## Step 2. Determine Structure

Plan the directory layout. Every skill gets `SKILL.md`. Add subdirectories only when needed:

```
skill-name/
├── SKILL.md              # Always — core instructions
├── references/           # If detailed docs exist (patterns, API refs)
│   └── *.md
└── templates/            # If example/starter files exist
    └── *
```

**Progressive disclosure principle**: SKILL.md stays lean (<100 lines ideally, <500 max). Move detailed patterns and code examples to `references/`. Move example configs and starter files to `templates/`.

Information lives in ONE place — either SKILL.md or a reference file, never both.

---

## Step 3. Write SKILL.md

Read `references/best-practices.md` for the structure checklist and `references/prompting-for-skills.md` for the prompting guidelines, then write the skill file.

### Frontmatter (required fields)

```yaml
---
name: skill-name
description: Single-line description with trigger words. State WHAT it does and WHEN to use it.
argument-hint: "<required> [optional]"
allowed-tools:
  - Read
  - Bash(specific-command *)
---
```

Read `references/frontmatter-reference.md` for all available fields.

### Body structure

Follow this order:

1. **H1 title** — Skill name
2. **One-line summary** — What it does (imperative form)
3. **Arguments** — What `$1`, `$2`, etc. mean
4. **Workflow table** — Step | Action | Completion Criteria
5. **Step details** — One H2 per step with concrete instructions
6. **Key Constraints** — Gotchas, important rules (if any)
7. **Reference Files** — Links to references/ and templates/ (if any)

See `templates/SKILL-template.md` for a starter file.

---

## Step 4. Write Reference Files

Create `references/*.md` for:

- Detailed code patterns (>10 lines of example code)
- API documentation or schemas
- Complex interaction patterns
- Domain-specific knowledge Claude doesn't have

Each reference file should have a clear H1 title and be self-contained.

---

## Step 5. Write Templates

Create `templates/*` for:

- Example configuration files (YAML, JSON, etc.)
- Starter manifests the user copies and customizes
- Sample data files

Add inline comments explaining each section.

---

## Step 6. Verify

After writing all files, display:

```
Skill created: <path>/skill-name/

Files:
  SKILL.md              — Core instructions
  references/foo.md     — (if created)
  templates/bar.yml     — (if created)

Test: Type /skill-name to verify it appears in autocomplete.
```

---

## Key Constraints

- **Description must be a single-line string** — YAML multiline indicators (`>-`, `|`) are NOT parsed correctly by Claude Code's skill indexer.
- **allowed-tools uses glob patterns** — `Bash(git *)` matches `git status`, `git diff`. Shell operators (`&&`, `||`, `|`) break matching.
- **Keep SKILL.md lean** — If the skill body exceeds ~100 lines, extract details to `references/`.
- **Don't create README, CHANGELOG, or docs** — Only create files the agent needs to execute the skill.
- **Say what TO DO, not what NOT to do** — Positive instructions are more effective (see `references/prompting-for-skills.md`).
- **Provide context for WHY** — Explaining motivation helps Claude generalize correctly.
- **Don't over-prompt** — Claude 4.5/4.6 is proactive; aggressive "CRITICAL: MUST ALWAYS" triggers over-action.

---

## Reference Files

- `references/best-practices.md` — Progressive disclosure, description writing, allowed-tools, structure patterns
- `references/frontmatter-reference.md` — All frontmatter fields, invocation control, string substitutions
- `references/prompting-for-skills.md` — Claude prompting best practices applied to skill content writing
- `templates/SKILL-template.md` — Starter SKILL.md to copy and customize
