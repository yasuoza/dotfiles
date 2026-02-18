---
name: copilot-codex
description: Delegate code implementation or review tasks to an external coding agent via the copilot CLI tool. Use when the user explicitly requests delegation with phrases like "Use codex", "Use copilot-codex", or similar. This skill provides access to an external expert coding agent specialized in code generation, review, and refactoring tasks.
user-invocable: true
allowed-tools:
  - Bash(copilot *)
---

# Copilot Codex

This skill delegates tasks to the `copilot` CLI, an external coding agent with its own specialized model. The copilot agent provides an independent perspective and specialized code generation capabilities that complement your own analysis. Your role in this skill is exclusively to gather context, construct a high-quality prompt, execute the `copilot` command, and then review the output for the user.

## Invocation Command

```bash
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "<prompt>"
```

Flags: `--yolo` skips confirmations, `--no-ask-user` prevents interactive prompts, `--silent` reduces verbose output, `--stream on` streams the response, `--model` selects the model, `--prompt` passes the task.

## Workflow

1. **Read relevant files** to understand the codebase structure, conventions, and constraints. This context is what makes the delegated prompt effective.
2. **Construct a detailed prompt** that includes:
   - File paths and relevant code snippets
   - Goal, requirements, and constraints
   - Language, framework, coding standards, and dependencies
   - Output language instruction: **always append** `"Match the language of the codebase's comments and documentation in your review output."` to the prompt
3. **Execute the copilot command** with the constructed prompt. Always run the command — this is the core purpose of this skill.
4. **Review the copilot output** and present it to the user. Validate generated code for correctness before accepting it.

## Examples

### Code Review

<example>
User: "Use codex to review PR #38"

Step 1 — Gather context:

- Read the PR diff via `gh pr diff 38`
- Read key files changed in the PR to understand existing patterns

Step 2 — Construct prompt:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Review the following PR changes for correctness, security, and adherence to project conventions. The project is a Python Lambda function using AWS SAM. Here are the changes: [diff content]. Key files for context: [relevant code]. Focus on: potential bugs, edge cases, and improvements."
```

Step 3 — Execute the copilot command.
Step 4 — Review the copilot output for accuracy and present findings to the user.
</example>

### Implementation

<example>
User: "Use codex to add input validation to the API endpoint"

Step 1 — Gather context:

- Read the target file (e.g., `agent/agent.py`) and related modules
- Read existing tests to understand testing patterns
- Check for existing validation patterns or utility functions in the codebase

Step 2 — Construct prompt:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Add input validation to the /invocations endpoint in chat-agent/agent/agent.py. The project is a Python FastAPI app using Pydantic. Current code: [relevant code]. Requirements: 1) Validate prompt length (max 10000 chars), 2) Validate session_id format (UUID). Existing patterns: [test examples, Pydantic models]. Write the implementation and corresponding tests following the existing test style. Match the language of the codebase's comments and documentation in your output."
```

Step 3 — Execute the copilot command.
Step 4 — Review the generated code for correctness, security, and adherence to project conventions before presenting to the user.
</example>

### Refactoring

<example>
User: "Use codex to refactor the tool functions to reduce duplication"

Step 1 — Gather context:

- Read all tool function files to identify duplication patterns
- Read imports and dependencies to understand coupling
- Read tests to ensure refactoring preserves existing behavior

Step 2 — Construct prompt:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Refactor the tool functions in chat-agent/agent/tools/ to reduce code duplication. Current files: [file list with code]. Common patterns found: [identified duplication]. Constraints: 1) Maintain backward compatibility — all existing function signatures must remain unchanged, 2) Keep all existing tests passing, 3) Follow the existing coding style. Suggest a refactoring plan with specific code changes. Match the language of the codebase's comments and documentation in your output."
```

Step 3 — Execute the copilot command.
Step 4 — Review the refactoring suggestions for correctness and verify they don't break existing interfaces before presenting to the user.
</example>

## Notes

- Requires the `copilot` CLI to be installed and on PATH.
- This skill excels at implementation, code generation, and code review through the external agent.
