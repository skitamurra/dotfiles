#!/usr/bin/env bash

# ── Tokyo Night TrueColor palette ────────────────────────────────────────
RST=$'\033[0m'

# Text colors
FG_MAIN=$'\033[38;2;192;202;245m'  # #c0caf5 main text
FG_BLUE=$'\033[38;2;122;162;247m'  # #7aa2f7 accent blue
FG_CYAN=$'\033[38;2;115;218;202m'  # #73daca accent cyan
FG_PURP=$'\033[38;2;187;154;247m'  # #bb9af7 accent purple
FG_DIM=$'\033[38;2;86;95;137m'     # #565f89 dim (separators)

# Status colors
FG_OK=$'\033[38;2;158;206;106m'    # #9ece6a green
FG_WARN=$'\033[38;2;224;175;104m'  # #e0af68 yellow
FG_CRIT=$'\033[38;2;247;118;142m'  # #f7768e red

SEP="${FG_DIM} │ ${RST}"

# ── Helpers ───────────────────────────────────────────────────────────────
status_fg() {
  local remaining=$(( 100 - $1 ))
  if   [ "$remaining" -le 10 ]; then echo "$FG_CRIT"
  elif [ "$remaining" -le 30 ]; then echo "$FG_WARN"
  else echo "$FG_OK"
  fi
}

# ── Input ─────────────────────────────────────────────────────────────────
input=$(cat)
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')
DIR_DISPLAY="${CURRENT_DIR##*/}"
[ -z "$DIR_DISPLAY" ] && DIR_DISPLAY="~"

# ── Git branch ────────────────────────────────────────────────────────────
GIT_BRANCH=""
if git -C "$CURRENT_DIR" rev-parse --git-dir &>/dev/null 2>&1; then
  BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
  if [ -n "$BRANCH" ]; then
    GIT_BRANCH="  $BRANCH"
  else
    COMMIT=$(git -C "$CURRENT_DIR" rev-parse --short HEAD 2>/dev/null)
    [ -n "$COMMIT" ] && GIT_BRANCH="  HEAD:$COMMIT"
  fi
fi

# ── Context usage ─────────────────────────────────────────────────────────
CTX_USED=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
CTX_INT=0
[ -n "$CTX_USED" ] && CTX_INT=${CTX_USED%.*}
CTX_FG=$(status_fg "${CTX_INT:-0}")

# ── Rate limits (from statusline input) ───────────────────────────────────
_fmt_reset() {
  local ts="$1" days="$2"
  [ -z "$ts" ] && return
  local now reset_epoch diff
  now=$(date +%s)
  # Support both Unix timestamp (integer) and date string
  if [[ "$ts" =~ ^[0-9]+$ ]]; then
    reset_epoch=$ts
  else
    reset_epoch=$(date -d "$ts" +%s 2>/dev/null) || return
  fi
  diff=$(( reset_epoch - now ))
  [ "$diff" -le 0 ] && echo "now" && return
  if [ "$days" = "1" ]; then
    local d=$(( diff / 86400 ))
    local h=$(( (diff % 86400) / 3600 ))
    if [ "$d" -gt 0 ]; then echo "${d}d${h}h"; else echo "${h}h"; fi
  else
    local h=$(( diff / 3600 ))
    local m=$(( (diff % 3600) / 60 ))
    if [ "$h" -gt 0 ]; then echo "${h}h${m}m"; else echo "${m}m"; fi
  fi
}

UTIL=$(echo "$input"   | jq -r '.rate_limits.five_hour.used_percentage // empty')
UTIL_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
RESET_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
RESET_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# ── Assemble status line ───────────────────────────────────────────────────
ICON=$'󰚩'
out=""

# model
out+="${FG_BLUE}${ICON} ${FG_MAIN}${MODEL_DISPLAY}"

# dir / git
out+="${SEP}${FG_CYAN} ${FG_MAIN}${DIR_DISPLAY}${FG_PURP}${GIT_BRANCH}"

# line 1
printf "%s${RST}\n" "$out"

# line 2: usage
line2=""

# ctx
line2+="${FG_MAIN}ctx: ${CTX_FG}${CTX_INT}%"

# rate
if [ -n "$UTIL" ]; then
  R5=$(awk "BEGIN { printf \"%d\", ${UTIL} }")
  [ "$R5" -gt 100 ] && R5=100
  line2+="${SEP}${FG_MAIN}5h: $(status_fg "$R5")${R5}%"
  RST5=$(_fmt_reset "$RESET_5H" "")
  [ -n "$RST5" ] && line2+="${FG_DIM}(↻${RST5})${RST}"

  if [ -n "$UTIL_7D" ]; then
    R7=$(awk "BEGIN { printf \"%d\", ${UTIL_7D} }")
    [ "$R7" -gt 100 ] && R7=100
    line2+="${SEP}${FG_MAIN}7d: $(status_fg "$R7")${R7}%"
    RST7=$(_fmt_reset "$RESET_7D" "1")
    [ -n "$RST7" ] && line2+="${FG_DIM}(↻${RST7})${RST}"
  fi

fi

printf "%s${RST}\n" "$line2"
