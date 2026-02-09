---
name: copilot-codex
description: Delegate code implementation or review tasks to an external coding agent via the copilot CLI tool. Use when the user explicitly requests delegation with phrases like "Use codex", "Use copilot-codex", or similar. This skill provides access to an external expert coding agent specialized in code generation, review, and refactoring tasks.
context: fork
user-invocable: true
allowed-tools:
  - Read
  - Bash(copilot *)
---

# Copilot Codex

Triggered when the user requests delegation with phrases like "use codex", "use codex for this task", "use copilot-codex", or "delegate this to codex".

Well-suited for: complex implementation, code generation, refactoring, code review, and getting an additional expert perspective.

## Invocation Command

```bash
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "<prompt>"
```

Flags: `--yolo` skips confirmations, `--no-ask-user` prevents interactive prompts, `--silent` reduces verbose output, `--stream on` streams the response, `--model` selects the model, `--prompt` passes the task.

## Workflow

1. **Read relevant files** to understand the codebase structure, conventions, and constraints. This context is what makes the delegated prompt effective.
2. **Construct a detailed prompt** including:
   - File paths and relevant code snippets
   - Goal, requirements, and constraints
   - Language, framework, coding standards, and dependencies
   - Examples: "Implement a user authentication system with JWT tokens", "Review this code for security vulnerabilities and suggest improvements"
3. **Execute** the copilot command with the constructed prompt.
4. **Review the output** and present it to the user. Validate generated code for correctness before accepting it.

## Example

User: "Use codex to implement a REST API endpoint for user registration"

1. Read the existing route files, models, and middleware to understand patterns in use.
2. Run: `copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Implement a REST API endpoint for user registration in Express.js. The project uses [conventions from step 1]. Requirements: ..."`
3. Review and present the result.

## Notes

- Requires the `copilot` CLI to be installed and on PATH.
- This skill excels at implementation and code generation, not exploration or architectural planning.
