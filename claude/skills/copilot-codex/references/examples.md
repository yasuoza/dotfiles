# Copilot Codex -- Usage Examples

## Code Review

User: "Use codex to review PR #38"

1. **Gather context**: `gh pr diff 38`, read key changed files
2. **Write prompt file** (`/tmp/copilot-prompt.txt`):
   ```
   Review the following PR changes for correctness, security, and adherence
   to project conventions. The project is a Python Lambda function using AWS SAM.

   Changes:
   <diff>
   actual diff content
   </diff>

   Key files for context:
   <context>
   actual code
   </context>

   Focus on: potential bugs, edge cases, and improvements.
   ```
3. **Execute**: `bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt`
4. **Return** output as-is

---

## Implementation

User: "Use codex to add input validation to the API endpoint"

1. **Gather context**: read target file, related modules, existing tests, validation patterns
2. **Write prompt file** (`/tmp/copilot-prompt.txt`):
   ```
   Add input validation to the /invocations endpoint in chat-agent/agent/agent.py.
   The project is a Python FastAPI app using Pydantic.

   Current code:
   <code>actual code</code>

   Requirements:
   1) Validate prompt length (max 10000 chars)
   2) Validate session_id format (UUID)

   Existing patterns:
   <tests>actual test code</tests>
   <models>actual Pydantic models</models>

   Write the implementation and corresponding tests following the existing test style.
   ```
3. **Execute**: `bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt`
4. **Return** output as-is

---

## Refactoring

User: "Use codex to refactor the tool functions to reduce duplication"

1. **Gather context**: read all tool files, imports, dependencies, tests
2. **Write prompt file** (`/tmp/copilot-prompt.txt`):
   ```
   Refactor the tool functions in chat-agent/agent/tools/ to reduce code duplication.

   Current files:
   <files>actual file list with code</files>

   Common patterns found:
   <duplication>identified duplication details</duplication>

   Constraints:
   1) Maintain backward compatibility -- all existing function signatures unchanged
   2) Keep all existing tests passing
   3) Follow existing coding style

   Suggest a refactoring plan with specific code changes.
   ```
3. **Execute**: `bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt`
4. **Return** output as-is

---

## Follow-up (any task type)

User: "Tell codex to also add error messages for the validation"

1. **Write prompt file** (`/tmp/copilot-prompt.txt`) -- only include follow-up instructions, copilot retains prior context:
   ```
   Add user-friendly error messages for each validation rule added in the previous step.

   Requirements:
   1) prompt length error: "Prompt must be 10,000 characters or fewer"
   2) session_id format error: "Session ID must be a valid UUID"

   Return the updated code and tests.
   ```
2. **Execute**: `bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt --resume <session_id>`
3. **Return** output as-is (session ID unchanged)
