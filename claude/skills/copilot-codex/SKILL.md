---
name: copilot-codex
description: Delegate code implementation or review tasks to an external coding agent via the copilot CLI tool. Use when the user explicitly requests delegation with phrases like "Use codex", "Use copilot-codex", or similar. This skill provides access to an external expert coding agent specialized in code generation, review, and refactoring tasks.
allowed-tools:
  - Bash(bash */run_copilot.sh *)
---

# Copilot Codex

Delegate tasks to the `copilot` CLI agent. Gather context, write a prompt file, execute via wrapper script, return raw output.

## Workflow

1. **Detect session**: check conversation for a prior `COPILOT_SESSION_ID`. If found, this is a follow-up.
2. **Gather context**: read relevant files so copilot can work without exploring itself. Include actual code.
3. **Write prompt file**: save a detailed prompt to a temp file (convention: `/tmp/copilot-prompt.txt`).
4. **Execute**: run the wrapper script (see below).
5. **Return raw output**: never edit, summarize, or reformat. Include `COPILOT_SESSION_ID` in your response.

## Execution

Always use `scripts/run_copilot.sh`. Never call `copilot` directly.

```bash
# First invocation
bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt

# Follow-up (resume prior session)
bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt --resume <session_id>

# Non-English codebase
bash <skill_path>/scripts/run_copilot.sh /tmp/copilot-prompt.txt --lang Japanese
```

The script reads the prompt from the file (multi-line safe), appends a language instruction, and handles all copilot CLI flags internally.

## Prompt Construction

Include actual code from relevant files, goal with acceptance criteria, constraints, and existing patterns (tests, naming conventions). For task-specific prompt templates, see [references/examples.md](references/examples.md).

## Key Rules

- Always execute -- delegation is the core purpose of this skill.
- Never edit copilot output -- return it raw.
- Restate `COPILOT_SESSION_ID` in every response so it survives context compaction.
- Session ID is stable across resumes; no need to re-query on follow-ups.
