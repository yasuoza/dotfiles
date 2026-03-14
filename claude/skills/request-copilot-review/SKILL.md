---
name: request-copilot-review
description: Request or re-request a GitHub Copilot review on a Pull Request. Use when the user says "copilot review", "request copilot review", "add copilot as reviewer", "Copilot にレビュー依頼", "再レビュー", or any variation of requesting GitHub Copilot to review a PR. Also triggers when the user wants to add a bot reviewer to a PR. If no PR number is given, operates on the current branch's PR.
argument-hint: "[PR number or URL]"
allowed-tools:
  - Bash(gh pr view *)
  - Bash(gh repo view *)
  - Bash(gh api *)
---

# Request Copilot Review

Request `copilot-pull-request-reviewer[bot]` to review a GitHub PR. Automatically detects whether this is an initial request or a re-review.

## Arguments

| Argument | Required | Description |
| --- | --- | --- |
| `<PR>` | No | PR number (e.g., `123`) or URL. If omitted, uses the PR for the current branch. |

## Workflow

Run the following steps using Bash. All output messages should be in English.

### Step 1: Resolve PR

```bash
# With argument:
gh pr view <PR> --json number,url --jq '{number: .number, url: .url}'

# Without argument (current branch):
gh pr view --json number,url --jq '{number: .number, url: .url}'
```

If this fails, output the following and **stop** — do not proceed:

> No PR found for the current branch. Create a PR first.

### Step 2: Check if a review request is already pending

```bash
gh pr view <NUMBER> --json reviewRequests --jq '[.reviewRequests[] | select(.login == "Copilot" or .login == "copilot-pull-request-reviewer[bot]")] | length'
```

If the result is > 0, output and **stop**:

> Copilot review already pending on PR #<NUMBER>.

### Step 3: Request review via GitHub API

Both initial requests and re-reviews use the same API endpoint — GitHub handles the distinction automatically. `gh pr edit --add-reviewer` does not support bot accounts, so use the REST API directly:

Construct the command as a single line (glob permission patterns don't match across newlines):

```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

Then use the result:

```bash
gh api "repos/<REPO>/pulls/<NUMBER>/requested_reviewers" -X POST -f 'reviewers[]=copilot-pull-request-reviewer[bot]'
```

If the API call succeeds, output:

> Requested Copilot review on PR #<NUMBER>. <URL>

If the API call fails, output the error message from `gh api` as-is so the user can diagnose.
