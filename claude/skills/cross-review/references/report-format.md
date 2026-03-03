# Cross Review Report Format

## Merge Strategy

When combining results from both reviewers:

1. **Consensus detection**: Match findings by file path and topic. Two findings are consensus if they reference the same file, address the same logical issue (e.g., both flag a missing null check on the same variable), regardless of exact line numbers.
2. **Severity ranking**: Critical > High > Medium > Low. Consensus findings are elevated by one level (max Critical).
3. **Deduplication**: For consensus items, use the more detailed explanation. Attribute to both reviewers.

## Report Template

```markdown
### Cross Review Report

**Target**: {diff description -- PR number, file paths, or commit range}
**Reviewers**: Claude Opus, GitHub Copilot (codex)

---

#### Consensus Findings

Issues identified by both reviewers. Highest confidence -- prioritize these.

| # | Severity | Location | Issue | Suggested Fix |
|---|----------|----------|-------|---------------|
| 1 | ...      | file:line | ...  | ...           |

> If no consensus findings, write: "No overlapping issues found -- review individual findings below."

#### Claude Opus Findings

Issues raised only by Opus.

| # | Severity | Location | Issue | Suggested Fix |
|---|----------|----------|-------|---------------|
| 1 | ...      | file:line | ...  | ...           |

#### GitHub Copilot Findings

Issues raised only by Copilot.

| # | Severity | Location | Issue | Suggested Fix |
|---|----------|----------|-------|---------------|
| 1 | ...      | file:line | ...  | ...           |

#### Positive Observations

Good patterns or code quality highlights noted by either reviewer.

- ...

#### Recommended Actions

Prioritized action list synthesized from all findings, ordered by severity.

1. **[Critical]** ...
2. **[High]** ...
3. ...
```

## Follow-up Reviews

For follow-up reviews, prepend a resolution status table:

```markdown
#### Resolution Status

| Previous Finding | Status | Notes |
|-----------------|--------|-------|
| ...             | Resolved / Partially Resolved / Unresolved | ... |
```

## Partial Failure

If only one reviewer produced results, skip the Consensus section and note the failure:

```markdown
> **Note**: {Reviewer name} did not produce results ({reason}). This report reflects a single-reviewer analysis.
```
