#!/usr/bin/env bash
# Ghost memory sync hook for Claude Code Stop event.
# Runs only when ghost memory adapter exists.

set -u

GHOST_HOME="${GHOST_HOME:-$HOME/.local/share/ghost}"
GHOST_MEMORY_SCRIPT="${GHOST_MEMORY_SCRIPT:-$GHOST_HOME/memory.py}"
GHOST_MEMORY_DB="${GHOST_MEMORY_DB:-$GHOST_HOME/memory.db}"
GHOST_AUTO_CAPTURE_ON_STOP="${GHOST_AUTO_CAPTURE_ON_STOP:-1}"
GHOST_AUTO_CAPTURE_MAX_CHARS="${GHOST_AUTO_CAPTURE_MAX_CHARS:-400}"
GHOST_AUTO_SOURCE="${GHOST_AUTO_SOURCE:-claude-stop-hook}"
GHOST_AUTO_CAPTURE_REQUIRE_SUMMARY="${GHOST_AUTO_CAPTURE_REQUIRE_SUMMARY:-1}"

INPUT=$(cat || true)

if ! command -v python3 >/dev/null 2>&1; then
  exit 0
fi

if [ ! -f "$GHOST_MEMORY_SCRIPT" ]; then
  exit 0
fi

if [ "$GHOST_AUTO_CAPTURE_ON_STOP" = "1" ] && command -v jq >/dev/null 2>&1; then
  if ! [[ "$GHOST_AUTO_CAPTURE_MAX_CHARS" =~ ^[0-9]+$ ]]; then
    GHOST_AUTO_CAPTURE_MAX_CHARS=400
  fi

  SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || true)
  CURRENT_DIR=$(echo "$INPUT" | jq -r '.workspace.current_dir // empty' 2>/dev/null || true)
  MODEL=$(echo "$INPUT" | jq -r '.model.display_name // empty' 2>/dev/null || true)
  SUMMARY=$(echo "$INPUT" | jq -r '.summary // .stop_hook_active_session.summary // .stop_hook_active_session.stop_reason // empty' 2>/dev/null || true)

  if [ "$GHOST_AUTO_CAPTURE_REQUIRE_SUMMARY" = "1" ] && [ -z "$SUMMARY" ]; then
    SUMMARY_TRIMMED=""
  else
    [ -z "$SUMMARY" ] && SUMMARY="Claude session completed"

    if [ -n "$CURRENT_DIR" ]; then
      SUMMARY="${SUMMARY} @${CURRENT_DIR}"
    fi
    if [ -n "$MODEL" ]; then
      SUMMARY="${SUMMARY} [model:${MODEL}]"
    fi
    if [ -n "$SESSION_ID" ]; then
      SUMMARY="${SUMMARY} [session:${SESSION_ID}]"
    fi

    SUMMARY_TRIMMED=$(echo "$SUMMARY" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | cut -c1-"$GHOST_AUTO_CAPTURE_MAX_CHARS")
  fi

  if [ -n "$SUMMARY_TRIMMED" ]; then
    python3 "$GHOST_MEMORY_SCRIPT" add \
      --db "$GHOST_MEMORY_DB" \
      --source "$GHOST_AUTO_SOURCE" \
      --text "$SUMMARY_TRIMMED" >/dev/null 2>&1 || true
  fi
fi

# Best-effort sync only. Never block Claude session finalization.
python3 "$GHOST_MEMORY_SCRIPT" sync --db "$GHOST_MEMORY_DB" >/dev/null 2>&1 || true

exit 0
