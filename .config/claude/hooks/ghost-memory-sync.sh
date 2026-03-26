#!/usr/bin/env bash
# Ghost memory sync hook for Claude Code Stop event.
# Runs only when ghost memory adapter exists.

set -u

GHOST_HOME="${GHOST_HOME:-$HOME/.local/share/ghost}"
GHOST_MEMORY_SCRIPT="${GHOST_MEMORY_SCRIPT:-$GHOST_HOME/memory.py}"
GHOST_MEMORY_DB="${GHOST_MEMORY_DB:-$GHOST_HOME/memory.db}"

# Read stdin from hook event to avoid broken pipes in Claude hooks.
cat >/dev/null || true

if ! command -v python3 >/dev/null 2>&1; then
  exit 0
fi

if [ ! -f "$GHOST_MEMORY_SCRIPT" ]; then
  exit 0
fi

# Best-effort sync only. Never block Claude session finalization.
python3 "$GHOST_MEMORY_SCRIPT" sync --db "$GHOST_MEMORY_DB" >/dev/null 2>&1 || true

exit 0
