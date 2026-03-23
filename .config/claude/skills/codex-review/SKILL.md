---
name: codex-review
description: >
  Ask Codex to review the current codebase or specific code and return its feedback.
  Use this skill whenever the user says "codexにレビューして", "codexにレビューを受けて",
  "codexでレビュー", "/codex-review", or asks to get a second opinion from Codex on
  code quality, test coverage, design decisions, or potential bugs — even if they don't
  say "review" explicitly (e.g., "codexに確認してもらって", "codexに見てもらって").
  Trigger proactively when the user finishes implementing a feature and asks what to do next,
  or before publishing/merging, as a natural quality gate.
---

# codex-review

Send the current code to Codex for an independent review and surface its feedback clearly.

## How to use

1. **Determine what to review** — the whole codebase (default), a specific file, or a
   specific concern. If the user specifies a focus (e.g., `/codex-review test coverage`
   or `/codex-review src/app.rs`), narrow the prompt accordingly.

2. **Build the review prompt** — Codex works best with a concrete, scoped ask.
   Include the working directory so it can read the files directly.

3. **Call the Codex tool**:
   ```
   mcp__codex__codex(
     prompt = <review prompt below>,
     cwd = <current working directory>,
     sandbox = "read-only"
   )
   ```

4. **Present the results** — relay Codex's feedback directly to the user. Don't filter
   or summarize unless asked. If Codex raises an issue you disagree with, note your
   perspective briefly after relaying its feedback.

5. **Offer to act on it** — after presenting, ask if the user wants to address any of
   the findings now.

## Review prompt template

Adapt this to the focus area if one was specified:

```
Please review this codebase and give feedback on:
- Code quality and clarity
- Test coverage (gaps, edge cases not covered)
- Potential bugs or logic errors
- Design concerns or architectural issues
- Anything that stands out as risky or worth improving

Be direct and specific. Point to files and line numbers where relevant.
```

**With focus area** (e.g., "test coverage"):
```
Please review this codebase with a focus on [FOCUS].
Also flag anything else that looks obviously wrong or risky.
```

**With specific file** (e.g., "src/app.rs"):
```
Please review src/app.rs specifically.
Look for correctness, edge cases, and code quality issues.
```

## sandbox setting

Always use `sandbox = "read-only"` — Codex only needs to read the code.
