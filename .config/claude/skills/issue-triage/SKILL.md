---
name: issue-triage
description: >
  Fetch a GitHub issue, analyze it against the codebase, and propose a fix strategy.
  Use when the user says "issue", "issue #N", "issue対応", "issueを確認", "issue triage",
  or references a GitHub issue number they want investigated. Also trigger when the user
  pastes a GitHub issue URL.
---

# issue-triage

Fetch a GitHub issue, investigate the codebase for relevant code, and propose an
actionable fix strategy — without implementing anything.

## Input

The user provides one of:
- An issue number (e.g., `#5`, `5`)
- A GitHub issue URL
- Just the skill invocation (list open issues and ask which one)

## Steps

### 1. Identify the repository

Determine the GitHub repo from the current working directory:

```bash
gh repo view --json nameWithOwner -q '.nameWithOwner'
```

If this fails, ask the user for the repo.

### 2. Fetch the issue

```bash
gh issue view <number> --json title,body,labels,assignees,comments,state
```

If no number was given, list open issues and ask:

```bash
gh issue list --state open --limit 20
```

### 3. Summarize the issue

Output a brief summary in this format:

```
## Issue #N: <title>

**Labels:** ...
**State:** ...

### Problem
<1-3 sentences summarizing what's wrong or what's requested>
```

### 4. Investigate the codebase

Based on the issue description:
- Search for relevant files, functions, and types mentioned or implied
- Read the specific code sections that would need to change
- Check for existing tests related to the area

Use Grep, Glob, and Read tools — not Bash for searching.

### 5. Propose a strategy

Output an actionable plan:

```
### Proposed approach

1. **Root cause**: <what's actually wrong / what needs to change>
2. **Files to modify**: <list with brief rationale>
3. **Approach**: <how to fix it, in concrete terms>
4. **Tests**: <what tests to add or update>
5. **Risk**: <anything that could go wrong or needs extra care>
```

## Rules

- Do NOT implement anything. This skill is for analysis only.
- If the issue is unclear or underspecified, say so and suggest clarifying questions
  to post on the issue.
- If the fix is trivial (< 5 lines, obvious), say so — the user may want to just do it
  rather than plan it.
- Keep the strategy concrete. "Refactor the module" is not a strategy.
  "Add a `state_changed` field to `PullRequest` and filter on it in `poll_prs()`" is.
