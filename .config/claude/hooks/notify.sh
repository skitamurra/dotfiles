#!/bin/bash
# Claude Code ターミナル通知スクリプト (WezTerm OSC 9 + user var)
TITLE="${1:-Claude Code}"
MESSAGE="${2:-needs your attention}"
STATE="${3:-}"  # waiting | done | idle | "" (リセット)

# プロセスツリーを遡ってClaudeのTTY（/dev/pts/*）を探す
find_tty() {
  local pid=$$
  while [ "$pid" -gt 1 ]; do
    local fd0
    fd0=$(readlink /proc/$pid/fd/0 2>/dev/null)
    if [[ "$fd0" == /dev/pts/* ]]; then
      echo "$fd0"
      return 0
    fi
    pid=$(awk '/PPid/{print $2}' /proc/$pid/status 2>/dev/null)
    [ -z "$pid" ] && break
  done
  return 1
}

TTY_PATH=$(find_tty)

if [ -n "$TTY_PATH" ]; then
  # OSC 9: WezTermが通知として表示
  printf '\033]9;%s: %s\007' "$TITLE" "$MESSAGE" > "$TTY_PATH"

  # OSC 1337 SetUserVar: タブマーク用の状態をセット
  if [ -n "$STATE" ]; then
    printf '\033]1337;SetUserVar=CLAUDE_STATE=%s\007' "$(echo -n "$STATE" | base64 -w0)" > "$TTY_PATH"
  fi
fi

exit 0
