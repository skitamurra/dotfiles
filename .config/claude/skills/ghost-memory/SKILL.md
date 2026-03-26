---
name: ghost-memory
description: >
  Persist and recall coding memories through Ghost's memory.py adapter.
  Use this skill when users ask to save lessons learned, past decisions,
  project conventions, or to search previously stored context.
---

# ghost-memory

Use Ghost memory as a lightweight, local long-term memory for Claude sessions.

## Preconditions

- `python3` is installed.
- `GHOST_MEMORY_SCRIPT` points to a working `memory.py`.
- `GHOST_MEMORY_DB` points to a writable sqlite file.

Defaults:
- `GHOST_MEMORY_SCRIPT=$HOME/.local/share/ghost/memory.py`
- `GHOST_MEMORY_DB=$HOME/.local/share/ghost/memory.db`

## Commands

### Save memory

```bash
python3 "$GHOST_MEMORY_SCRIPT" add \
  --db "$GHOST_MEMORY_DB" \
  --source "claude" \
  --text "<記録したい内容>"
```

### Search memory

```bash
python3 "$GHOST_MEMORY_SCRIPT" search \
  --db "$GHOST_MEMORY_DB" \
  --query "<知りたい内容>" \
  --top-k 5
```

### Sync embeddings / index

```bash
python3 "$GHOST_MEMORY_SCRIPT" sync --db "$GHOST_MEMORY_DB"
```

## Usage notes

- Prefer concise, reusable memories (decision, trade-off, policy).
- Avoid secrets (tokens, private keys, credentials).
- If Ghost script is missing, skip gracefully and continue normal work.
