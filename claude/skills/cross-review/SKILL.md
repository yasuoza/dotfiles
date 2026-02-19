---
name: cross-review
description: Run code reviews in parallel using Claude Opus and GitHub Copilot (codex), then produce a unified report. Use when the user requests a cross-review, xreview, multi-LLM review, or wants diverse perspectives on code changes.
user-invocable: true
allowed-tools:
  - Task
  - Write
  - Bash(git diff*)
  - Bash(git log*)
  - Bash(gh pr diff*)
---

# Cross Review

Run two independent code reviews in parallel — one via Claude Opus (code-reviewer agent) and one via GitHub Copilot codex — then merge the results into a single unified report.

## Step 1: Identify the review target

Determine the diff to review based on user input:

- If the user specifies a PR number, run `gh pr diff <number>`.
- If the user specifies file paths, run `git diff HEAD -- <paths>`.
- Otherwise, run `git diff HEAD`. If empty, fall back to `git diff HEAD~1`.

If no diff is found after these steps, ask the user what to review.

Store the diff content for use in both review prompts.

## Step 2: Launch background reviews

<use_parallel_tool_calls>
The two reviews have no dependency on each other. Launch both Task tool calls in a single message so they execute concurrently. Both must use `run_in_background: true` so the user can continue working while reviews run.

### Review A: Claude Opus (code-reviewer)

| Parameter         | Value           |
| ----------------- | --------------- |
| subagent_type     | `code-reviewer` |
| model             | `opus`          |
| run_in_background | `true`          |

Include the full diff in the prompt and request review covering:

- Correctness and edge cases
- Security concerns
- Performance implications
- Maintainability and readability
- Concrete fix suggestions with file path and line number

### Review B: GitHub Copilot codex

| Parameter         | Value  |
| ----------------- | ------ |
| subagent_type     | `Bash` |
| run_in_background | `true` |

Execute the copilot CLI to perform the review:

```
copilot --yolo --no-ask-user --silent --stream on --model gpt-5.3-codex --prompt "<prompt>"
```

Build a self-contained prompt that includes:

- The full diff content
- A review request covering correctness, security, performance, and maintainability
- Language instruction: append `"Match the language of the codebase's comments and documentation in your output."` to the end of the prompt

<single_line_command>
The entire copilot command must be a single line. Use a single double-quoted string for the `--prompt` value. Avoid heredocs, `$(cat ...)`, or other multi-line constructs. The Bash permission pattern `Bash(copilot *)` uses glob matching, and `*` does not match newlines.
</single_line_command>
</use_parallel_tool_calls>

After launching both reviews, immediately inform the user that reviews are running in the background and they can continue working. Record the `output_file` paths returned by each Task call.

## Step 3: Collect results and produce unified report

Wait for both background reviews to complete by reading their `output_file` paths with the Read tool. Once both results are available, compare and merge the findings into the following structure:

<output_format>

### Cross Review Report

#### Consensus findings

Issues identified by both LLMs. These carry the highest confidence and warrant priority attention.

#### Claude Opus findings

Issues raised only by Opus. Include the target location (file:line) and a concrete fix suggestion for each.

#### GitHub Copilot findings

Issues raised only by Copilot.

#### Positive observations

Good implementation patterns or code quality highlights noted by either LLM.

#### Recommended actions

A prioritized action list synthesized from all findings, ordered by severity.

</output_format>
