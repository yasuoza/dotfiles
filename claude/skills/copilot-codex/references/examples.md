# Copilot Codex -- Usage Examples

## Code Review

User: "Use codex to review PR #38"

**Gather context:**
- Read the PR diff via `gh pr diff 38`
- Read key files changed in the PR to understand existing patterns

**Construct prompt and execute:**

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Review the following PR changes for correctness, security, and adherence to project conventions. The project is a Python Lambda function using AWS SAM. Here are the changes: <diff>actual diff content here</diff>. Key files for context: <context>actual code here</context>. Focus on: potential bugs, edge cases, and improvements. Match the language of the codebase's comments and documentation in your output."
```

**Return** the copilot output as-is to the user.

---

## Implementation

User: "Use codex to add input validation to the API endpoint"

**Gather context:**
- Read the target file (e.g., `agent/agent.py`) and related modules
- Read existing tests to understand testing patterns
- Check for existing validation patterns or utility functions in the codebase

**Construct prompt and execute:**

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Add input validation to the /invocations endpoint in chat-agent/agent/agent.py. The project is a Python FastAPI app using Pydantic. Current code: <code>actual code here</code>. Requirements: 1) Validate prompt length (max 10000 chars), 2) Validate session_id format (UUID). Existing patterns: <tests>actual test code here</tests> <models>actual Pydantic models here</models>. Write the implementation and corresponding tests following the existing test style. Match the language of the codebase's comments and documentation in your output."
```

**Return** the copilot output as-is to the user.

---

## Refactoring

User: "Use codex to refactor the tool functions to reduce duplication"

**Gather context:**
- Read all tool function files to identify duplication patterns
- Read imports and dependencies to understand coupling
- Read tests to ensure refactoring preserves existing behavior

**Construct prompt and execute:**

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "Refactor the tool functions in chat-agent/agent/tools/ to reduce code duplication. Current files: <files>actual file list with code here</files>. Common patterns found: <duplication>identified duplication details here</duplication>. Constraints: 1) Maintain backward compatibility — all existing function signatures must remain unchanged, 2) Keep all existing tests passing, 3) Follow the existing coding style. Suggest a refactoring plan with specific code changes. Match the language of the codebase's comments and documentation in your output."
```

**Return** the copilot output as-is to the user.
