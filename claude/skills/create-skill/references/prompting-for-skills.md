# Prompting Best Practices for Skill Content

Based on the official Claude prompting best practices (platform.claude.com), applied to writing SKILL.md content.

## Core Principles

### 1. Be explicit about desired behavior

Claude responds well to clear, specific instructions. Don't rely on implicit expectations.

```markdown
# Bad — vague
Check the files and fix issues.

# Good — explicit
Read the manifest YAML at `$1`. For each screenshot entry, navigate to the URL, apply cleanup, and take a viewport-only screenshot.
```

### 2. Provide context for WHY

Explaining motivation helps Claude generalize correctly.

```markdown
# Bad — rule without reason
Re-define helpers after every navigate_page call.

# Good — rule with context
Re-define helpers after every navigate_page call — the browser JS context resets on navigation, so window.__cleanup and window.__mask must be re-injected each time.
```

### 3. Say what TO DO, not what NOT to do

Positive instructions are more effective than negative ones.

```markdown
# Bad
Don't use full page screenshots.

# Good
Take viewport-only screenshots (visible area only) unless the manifest specifies fullPage: true.
```

### 4. Use XML tags for structured sections

XML tags help Claude distinguish instruction boundaries.

```markdown
<steps>
### 1. Read the manifest
...
### 2. Prepare the browser
...
</steps>
```

Useful tags: `<steps>`, `<example>`, `<constraints>`, `<output_format>`

## Claude 4.5/4.6 Specific

### 5. Don't over-prompt

Claude 4.5/4.6 models are more proactive than predecessors. Instructions that previously prevented under-triggering now cause **over-triggering**.

```markdown
# Bad — aggressive (causes over-triggering on newer models)
CRITICAL: You MUST ALWAYS use this tool when...

# Good — natural tone
Use this tool when the user asks to capture screenshots.
```

### 6. Keep instructions proportional

Claude is smart enough to generalize from concise instructions. Only add context Claude doesn't already have.

```markdown
# Bad — over-explaining something Claude already knows
JSON is a data format that uses key-value pairs enclosed in curly braces...

# Good — only domain-specific knowledge
The manifest uses a custom `cleanup.text_match` field: an array of exact text strings to match against .badge and span elements.
```

### 7. Encourage parallel tool calls

Explicitly instruct parallel execution where beneficial.

```markdown
Run these commands in parallel:
1. `git branch --show-current`
2. `git log --oneline -5`
3. `git status --short`
```

### 8. Default to action

Be explicit about wanting the skill to take action, not just suggest.

```markdown
# Bad — Claude may only suggest
Recommend changes to improve performance.

# Good — Claude will implement
Apply cleanup to hide development-only UI elements, then take the screenshot.
```

## Structural Patterns

### 9. Workflow tables + step details

A table overview gives Claude the full picture before diving into details.

```markdown
| Step | Action       | Completion Criteria          |
| ---- | ------------ | ---------------------------- |
| 1    | Read config  | Config parsed successfully   |
| 2    | Process data | Output generated             |
| 3    | Report       | Summary displayed to user    |

---

## Step 1. Read Config
Concrete instructions here...
```

### 10. Branching logic with bullet points

Use indented bullets for conditional flows.

```markdown
- User selects **"OK"** → Use the generated message as-is
- User selects **"Modify"** → Use the user's input
- User enters custom text via **"Other"** → Follow custom instructions
```

### 11. Error handling tables

Concise error handling at the end of the skill.

```markdown
| Error              | Action                    |
| ------------------ | ------------------------- |
| No staged changes  | Display message and exit  |
| Command failure    | Display error details     |
```

## Anti-Patterns to Avoid in Skills

1. **Over-engineering instructions** — Don't add error handling for impossible scenarios
2. **Redundant safeguards** — Trust Claude's intelligence; one clear instruction suffices
3. **Verbose boilerplate** — Every token in SKILL.md competes for context budget
4. **Hypothetical future requirements** — Only instruct for current behavior
5. **Meta-commentary** — Don't explain that you're explaining; just instruct
