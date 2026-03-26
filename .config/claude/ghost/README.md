# Ghost integration notes for Claude Code

This dotfiles repo integrates a minimal subset of
`Flowers-of-Romance/ghost` with existing Claude Code settings.

## What is integrated

- Environment variables for Ghost memory adapter path and DB path.
- Stop hook (`hooks/ghost-memory-sync.sh`) to run best-effort `memory.py sync`.
- A local Claude skill (`skills/ghost-memory/SKILL.md`) for add/search/sync workflows.

## Setup

1. Place Ghost's `memory.py` at:
   - `$HOME/.local/share/ghost/memory.py`
2. Ensure the DB path exists or is creatable:
   - `$HOME/.local/share/ghost/memory.db`
3. Install required Python dependencies for your Ghost checkout.

You can override defaults with environment variables in Claude settings:

- `GHOST_HOME`
- `GHOST_MEMORY_SCRIPT`
- `GHOST_MEMORY_DB`

## Safety

- Hook is best-effort and never blocks Claude completion.
- Missing Ghost install is treated as no-op.
- Do not store secrets in memory entries.
