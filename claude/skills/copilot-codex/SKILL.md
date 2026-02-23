---
name: copilot-codex
description: Delegate code implementation or review tasks to an external coding agent via the copilot CLI tool. Use when the user explicitly requests delegation with phrases like "Use codex", "Use copilot-codex", or similar. This skill provides access to an external expert coding agent specialized in code generation, review, and refactoring tasks.
user-invocable: true
allowed-tools:
  - Bash(copilot *)
---

# Copilot Codex

This skill delegates tasks to the `copilot` CLI, an external coding agent with its own specialized model. The copilot agent provides an independent perspective and specialized code generation capabilities that complement your own analysis.

<role>
Your role is exclusively to gather context, construct a high-quality prompt, execute the copilot command, and return the raw output to the user. You are a prompt engineer — the copilot agent does the implementation work, and the main agent handles the output.
</role>

## Invocation Command

### First invocation (no prior session ID in conversation)

```bash
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "<prompt>" && echo "COPILOT_SESSION_ID=$(ls -t ~/.copilot/session-state/ | head -1)"
```

### Subsequent invocations (session ID exists in conversation)

```bash
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --resume <session-id> --prompt "<prompt>"
```

The session ID does not change across resumes, so there is no need to re-query it. Using `--resume <session-id>` instead of `--continue` ensures the correct session is resumed even if other Copilot sessions have run in between. When Claude Code's context is cleared (new session), the stored session ID is naturally lost, so Copilot starts a fresh session automatically.

| Flag | Purpose |
|------|---------|
| `--yolo` | Skip confirmations |
| `--no-ask-user` | Prevent interactive prompts |
| `--silent` | Reduce verbose output |
| `--stream on` | Stream the response |
| `--model` | Select the model |
| `--prompt` | Pass the task as a single-line string |
| `--resume` | Resume a specific Copilot session by ID |

## Workflow

<workflow>

### Step 1: Detect session continuity

Check the conversation history for a previously stored Copilot session ID (from a prior invocation of this skill in the current session).

- If a session ID exists, this is a **follow-up invocation** — use `--resume <session-id>`.
- If no session ID exists, this is a **first invocation** — run without `--resume`.

### Step 2: Gather context

Read relevant files to understand the codebase structure, conventions, and constraints. This context is what makes the delegated prompt effective. Gather enough information so the copilot agent can work without needing to explore the codebase itself.

### Step 3: Construct the prompt

Build a detailed, self-contained prompt string that includes:

- File paths and relevant code snippets
- Goal, requirements, and constraints
- Language, framework, coding standards, and dependencies
- Output language instruction: always append `"Match the language of the codebase's comments and documentation in your output."` to the prompt

<prompt_quality>
The prompt is the single most important input to the copilot agent. Invest effort here — a well-constructed prompt with rich context produces significantly better results than a vague one. Include actual code snippets and file contents rather than placeholders like `[relevant code]`.
</prompt_quality>

### Step 4: Execute the copilot command

Run the copilot command with the constructed prompt. Always execute the command — this is the core purpose of this skill. Use `--resume <session-id>` if a session ID was found in Step 1.

<single_line_command>
The entire copilot command must be a single line. Use a single double-quoted string for the `--prompt` value, keeping everything on one line. Avoid heredocs, `$(cat ...)`, or other multi-line constructs. This is because the Bash permission pattern `Bash(copilot *)` uses glob matching, and `*` does not match newline characters — a multi-line command will trigger a permission prompt.
</single_line_command>

### Step 5: Return the raw output and session ID

Return the copilot output to the user as-is, without editing, summarizing, or reformatting. The main agent will handle review and processing — preserving the raw output avoids information loss and is easier for downstream processing.

- **First invocation**: Extract the Copilot session ID from the `COPILOT_SESSION_ID=...` line in the command output and explicitly include it in your response so it persists in the conversation context for future invocations.
- **Subsequent invocations**: The session ID is already known and does not change across resumes. Simply restate the existing session ID — do not run a separate command to re-query it.

</workflow>

## Examples

### Code Review

<example>
User: "Use codex to review PR #38"

Step 1 — Gather context:

- Read the PR diff via `gh pr diff 38`
- Read key files changed in the PR to understand existing patterns

Step 2 — Construct prompt and Step 3 — Execute:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Review the following PR changes for correctness, security, and adherence to project conventions. The project is a Python Lambda function using AWS SAM. Here are the changes: <diff>actual diff content here</diff>. Key files for context: <context>actual code here</context>. Focus on: potential bugs, edge cases, and improvements. Match the language of the codebase's comments and documentation in your output."
```

Step 4 — Return the copilot output as-is to the user.
</example>

### Implementation

<example>
User: "Use codex to add input validation to the API endpoint"

Step 1 — Gather context:

- Read the target file (e.g., `agent/agent.py`) and related modules
- Read existing tests to understand testing patterns
- Check for existing validation patterns or utility functions in the codebase

Step 2 — Construct prompt and Step 3 — Execute:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Add input validation to the /invocations endpoint in chat-agent/agent/agent.py. The project is a Python FastAPI app using Pydantic. Current code: <code>actual code here</code>. Requirements: 1) Validate prompt length (max 10000 chars), 2) Validate session_id format (UUID). Existing patterns: <tests>actual test code here</tests> <models>actual Pydantic models here</models>. Write the implementation and corresponding tests following the existing test style. Match the language of the codebase's comments and documentation in your output."
```

Step 4 — Return the copilot output as-is to the user.
</example>

### Refactoring

<example>
User: "Use codex to refactor the tool functions to reduce duplication"

Step 1 — Gather context:

- Read all tool function files to identify duplication patterns
- Read imports and dependencies to understand coupling
- Read tests to ensure refactoring preserves existing behavior

Step 2 — Construct prompt and Step 3 — Execute:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Refactor the tool functions in chat-agent/agent/tools/ to reduce code duplication. Current files: <files>actual file list with code here</files>. Common patterns found: <duplication>identified duplication details here</duplication>. Constraints: 1) Maintain backward compatibility — all existing function signatures must remain unchanged, 2) Keep all existing tests passing, 3) Follow the existing coding style. Suggest a refactoring plan with specific code changes. Match the language of the codebase's comments and documentation in your output."
```

Step 4 — Return the copilot output as-is to the user.
</example>

## Notes

- Requires the `copilot` CLI to be installed and on PATH.
- This skill excels at implementation, code generation, and code review through the external agent.
