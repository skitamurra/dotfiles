#!/bin/bash
# Pre-code-change git branch check (once per session)
# - Base branch: block immediately
# - Non-base branch: inject context to prompt Claude to verify appropriateness

# Read stdin to get session_id
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')

# Not in a git repo — pass silently
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  exit 0
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Block on base branches (always, not once-per-session)
for base in main master develop trunk; do
  if [ "$BRANCH" = "$base" ]; then
    printf '{"continue": false, "stopReason": "ベースブランチ (%s) 上での変更は禁止されています。作業ブランチを切ってから変更してください。"}\n' "$BRANCH"
    exit 0
  fi
done

# Context injection: once per session only
SENTINEL="/tmp/claude-branch-checked-${SESSION_ID}"
if [ -f "$SENTINEL" ]; then
  exit 0
fi
touch "$SENTINEL"

# Build context message
CONTEXT="【コード変更前の確認】現在のブランチ: ${BRANCH} / "
CONTEXT+="(1) ブランチ名が変更のスコープと一致しているか確認してください。 / "

# Warn if behind remote (uses last-fetched state; does not run git fetch)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
if [ -n "$UPSTREAM" ]; then
  BEHIND=$(git rev-list --count HEAD.."$UPSTREAM" 2>/dev/null || echo "0")
  if [ "$BEHIND" -gt 0 ]; then
    CONTEXT+="(2) リモートより ${BEHIND} コミット遅れています。git fetch && git pull を検討してください。"
  fi
fi

printf '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": "%s"}}\n' "$(echo "$CONTEXT" | sed 's/"/\\"/g')"
