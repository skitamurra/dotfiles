---
name: git-commit
description: >
  Stage meaningful diffs and create WHY-focused commits in Conventional Commits format.
  Use this skill when you're ready to commit completed code changes — either because the
  task explicitly includes committing, or because the user has specifically asked you to commit.
  Reads ~/commitlint.config.js for type/scope conventions if available.
---

# git-commit

Commit changes deliberately: stage the right things, write a message that explains *why*
the change exists (not just what changed), and verify quality gates before committing.

## When to commit

- **Task includes committing** (e.g., "implement X and commit"): commit automatically
  when implementation is complete and quality gates pass
- **Implementation-only task**: wait for explicit commit instruction from the user

Never commit proactively when the task scope is unclear.

## Quality gates — check before proceeding

1. **Tests pass** — run the project's test command if you can determine it (package.json,
   Makefile, etc.); if unknown, skip this check
2. **No linter/compiler errors** — run the project's lint/typecheck command if determinable;
   if unknown, skip this check
3. **Single logical unit** — if the diff spans unrelated concerns, split into multiple commits

Never use `--no-verify` to bypass hooks.

## Read the commit format

Check `~/commitlint.config.js` — if it exists, follow its `types` array and rules.
Otherwise use standard Conventional Commits.

Format:
```
type(scope): subject

body (optional)
```

Valid types (from commitlint.config.js): `feat`, `fix`, `docs`, `style`, `refactor`,
`perf`, `test`, `build`, `ci`, `chore`, `revert`

- **scope**: the module, domain, or area affected — optional
- **subject**: ≤72 chars, imperative mood, no period at end
- **body**: wrap at 100 chars; use when context or trade-offs would help a future reader

## Write a WHY-focused subject

The subject line answers *why this change exists*, not *what files changed*.

| Anti-pattern (WHAT) | Better (WHY) |
|---|---|
| `Add null check to UserService` | `fix(auth): prevent crash when unauthenticated users access profile` |
| `Update tests` | `test(api): cover token expiry mid-request edge case` |
| `Refactor login handler` | `refactor(auth): separate concerns to enable per-route permission overrides` |

**Structural vs behavioral**: If the change reorganizes code without changing behavior
(refactor, rename, move), say so explicitly — readers shouldn't have to audit the diff
to know whether runtime behavior changed.

## Stage and commit

```bash
# 1. Review what's changed
git diff
git diff --staged

# 2. Stage only what belongs in this logical unit
git add <files>          # preferred: explicit files
# git add -p <file>      # for partial staging when a file has mixed concerns

# 3. Commit
git commit -m "$(cat <<'EOF'
type(scope): why this change exists

Optional body explaining context or trade-offs.
EOF
)"
```

## Prefer small, frequent commits

If the diff covers multiple independent concerns, make separate commits rather than
bundling everything. Each commit should be independently understandable and revertable.
