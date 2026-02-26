---
name: copilot-codex
description: Delegate code implementation or review tasks to an external coding agent via the copilot CLI tool. Use when the user explicitly requests delegation with phrases like "Use codex", "Use copilot-codex", or similar. This skill provides access to an external expert coding agent specialized in code generation, review, and refactoring tasks.
allowed-tools:
  - Bash(copilot *)
---

# Copilot Codex

Delegate tasks to the `copilot` CLI agent by gathering context, constructing a high-quality prompt, executing the command, and returning raw output.

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

| Step | Action | Key Detail |
|------|--------|------------|
| 1 | Detect session continuity | Use `--resume <session-id>` if ID exists; otherwise first invocation |
| 2 | Gather context | Read relevant files so copilot can work without exploring itself |
| 3 | Construct prompt | Self-contained, single-line, with code snippets and constraints |
| 4 | Execute command | Run copilot -- this is the core purpose of the skill |
| 5 | Return raw output | Pass through unedited; include session ID on first invocation |

## Step 1. Detect Session Continuity

Check conversation history for a previously stored Copilot session ID.

- If a session ID exists: **follow-up invocation** -- use `--resume <session-id>`.
- If no session ID exists: **first invocation** -- run without `--resume`.

## Step 2. Gather Context

Read relevant files to understand codebase structure, conventions, and constraints. Gather enough information so the copilot agent can work without needing to explore the codebase itself.

## Step 3. Construct the Prompt

Build a detailed, self-contained prompt string that includes:

- File paths and relevant code snippets (actual content, not placeholders)
- Goal, requirements, and constraints
- Language, framework, coding standards, and dependencies
- Output language instruction: always append `"Match the language of the codebase's comments and documentation in your output."`

The prompt is the single most important input. Invest effort here -- a well-constructed prompt with rich context produces significantly better results than a vague one.

## Step 4. Execute the Command

Run the copilot command with the constructed prompt. Always execute -- this is the core purpose of this skill.

The entire command must be a single line. Use a single double-quoted string for the `--prompt` value. Avoid heredocs, `$(cat ...)`, or other multi-line constructs. The Bash permission pattern `Bash(copilot *)` uses glob matching and `*` does not match newlines -- a multi-line command will trigger a permission prompt.

## Step 5. Return Raw Output and Session ID

Return the copilot output to the user as-is, without editing, summarizing, or reformatting.

- **First invocation**: Extract the session ID from the `COPILOT_SESSION_ID=...` line and include it in your response so it persists for future invocations.
- **Subsequent invocations**: Restate the existing session ID. Do not re-query it.

## Key Constraints

- Requires the `copilot` CLI to be installed and on PATH.
- The `--prompt` value must be a single-line double-quoted string (no heredocs or multi-line constructs).
- Never edit, summarize, or reformat copilot output -- return it raw.
- This skill excels at implementation, code generation, and code review through the external agent.

## Reference Files

- [references/examples.md](references/examples.md) -- Detailed usage examples (Code Review, Implementation, Refactoring)
