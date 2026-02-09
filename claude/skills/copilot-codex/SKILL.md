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

## Overview

This skill enables Claude to delegate code implementation and review tasks to an external coding agent through the `copilot` CLI tool. When invoked, Claude constructs an appropriate prompt and delegates the work to the external agent.

## When to Use This Skill

Use this skill when the user explicitly requests delegation with phrases such as:

- "Use codex to implement this feature"
- "Use codex for this task"
- "Use copilot-codex"
- "Delegate this to codex"

This skill is particularly valuable for:

- Complex implementation tasks that benefit from specialized coding capabilities
- Code review and validation
- Scenarios where the user wants an additional expert perspective
- Tasks that require focused code generation or refactoring

## Invocation Command

The copilot CLI tool is invoked with the following command:

```bash
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.2-codex --prompt "<prompt>"
```

**Flag explanations:**

- `--yolo`: Execute without additional confirmations
- `--no-ask-user`: Do not prompt for user input during execution
- `--silent`: Minimize verbose output
- `--stream on`: Stream the response as it is generated
- `--model gpt-5.2-codex`: Specify the model to use
- `--prompt "<prompt>"`: The prompt to send to the agent

## Constructing Effective Prompts

When delegating tasks, construct prompts that:

1. **Provide clear context**

   - Include relevant file paths and code snippets
   - Explain the goal and requirements clearly
   - Specify any constraints or preferences

2. **Be specific about the task**

   - "Implement a user authentication system with JWT tokens"
   - "Review this code for security vulnerabilities and suggest improvements"
   - "Refactor this function to improve performance"

3. **Include necessary technical details**
   - Programming language and framework
   - Coding standards or style guidelines
   - Dependencies or libraries to use

## Example Workflow

**User request:** "Use codex to implement a REST API endpoint for user registration"

**Execution steps:**

1. Gather context by reading relevant files and understanding the codebase
2. Construct a detailed prompt with all necessary information
3. Execute the command: `copilot --yolo --no-ask-user --silent --stream on --model gpt-5.2-codex --prompt "Implement a REST API endpoint for user registration in Express.js. Requirements: ..."`
4. Present the agent's response to the user

## Best Practices

- **Always gather context first** - Read relevant files before delegating to understand the codebase structure and conventions
- **Construct detailed prompts** - The more context provided, the better the output quality
- **Review the output** - Always validate and review the generated code before accepting it
- **Use for appropriate tasks** - This skill excels at implementation and code generation, not exploration or architectural planning

## Notes

- This skill requires the `copilot` CLI tool to be installed and accessible in the system PATH
- The tool connects to the external coding agent via the copilot service
- Execution is performed via the Bash tool with the command specified above
