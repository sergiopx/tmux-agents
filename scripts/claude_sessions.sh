#!/usr/bin/env bash
#
# claude_sessions.sh — list Claude Code sessions across all projects
#
# Output (one per line, tab-separated):
#   <session-id> <TAB> <title> <TAB> <relative-time> <TAB> <project> [branch]
#
# Sorted by most recently modified. Title priority:
#   /rename or --name (custom-title) > Claude's auto title (ai-title) > first prompt
#
# Claude Code no longer maintains sessions-index.json reliably, so this scans
# the .jsonl transcripts under ~/.claude/projects and caches per-file results
# keyed by mtime, so repeat runs only re-parse sessions that changed.
#
# Usage:
#   claude_sessions.sh                # list sessions
#   claude_sessions.sh cwd <id>       # print the working directory of a session
#
# Options (tmux):
#   @tmuxagents-claude-scope   all (default) | project   — project = only sessions whose cwd is $PWD
#   @tmuxagents-claude-limit   max sessions to show (default 50, 0 = no limit)

PROJECTS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-agents/claude"
mkdir -p "$CACHE_DIR"

# ── Cache lookup helper ──────────────────────────────────────────────────────────
# Cache line format: mtime <TAB> cwd <TAB> branch <TAB> title
if [ "$1" = "cwd" ]; then
  [ -f "$CACHE_DIR/$2" ] && cut -f2 "$CACHE_DIR/$2"
  exit 0
fi

[ -d "$PROJECTS_DIR" ] || exit 0

tmux_opt() { tmux show-option -gqv "$1" 2>/dev/null; }
SCOPE=$(tmux_opt "@tmuxagents-claude-scope"); SCOPE="${SCOPE:-all}"
LIMIT=$(tmux_opt "@tmuxagents-claude-limit"); LIMIT="${LIMIT:-50}"
CWD_FILTER=""
[ "$SCOPE" = "project" ] && CWD_FILTER=$(pwd -P)

if stat -f '%m' / >/dev/null 2>&1; then
  mtime_of() { stat -f '%m' "$1"; }
else
  mtime_of() { stat -c '%Y' "$1"; }
fi

# ── Parse one transcript → cache line ───────────────────────────────────────────
parse_session() {
  local file="$1" mtime="$2"
  local cwd branch title

  # cwd + branch live on the first user record
  read -r cwd branch < <(
    grep -m1 '"type":"user"' "$file" \
      | jq -r '[(.cwd // ""), (.gitBranch // "")] | @tsv' 2>/dev/null \
      | tr '\t' ' '
  )

  # Custom title (from /rename or --name) — last one wins
  title=$(grep -o '"type":"custom-title","customTitle":"[^"]*"' "$file" 2>/dev/null \
    | tail -1 | sed 's/.*"customTitle":"//; s/"$//')

  # Claude's own generated title — usually near the tail of the file
  if [ -z "$title" ]; then
    title=$(tail -c 50000 "$file" | grep -o '"type":"ai-title","aiTitle":"[^"]*"' \
      | tail -1 | sed 's/.*"aiTitle":"//; s/"$//')
  fi

  # First real user prompt (skip slash-command and caveat records)
  if [ -z "$title" ]; then
    title=$(head -n 60 "$file" | jq -r '
      select(.type == "user")
      | .message.content
      | if type == "string" then . else (map(select(.type == "text")) | .[0].text // "") end
      | select(length > 0)
      | select(startswith("<") | not)
      | select(startswith("Caveat:") | not)
      | gsub("[\n\r\t]+"; " ")
      | .[0:80]
    ' 2>/dev/null | head -1)
  fi

  # Last resort: name the first slash command the user ran
  if [ -z "$title" ]; then
    title=$(head -n 60 "$file" | grep -o '<command-name>[^<]*</command-name>' | head -1 \
      | sed 's/<command-name>//; s/<\/command-name>//')
  fi

  [ -z "$title" ] && title="(empty session)"
  printf '%s\t%s\t%s\t%s\n' "$mtime" "$cwd" "$branch" "$title"
}

# ── Relative time ("3m", "2h", "5d") ────────────────────────────────────────────
NOW=$(date +%s)
rel_time() {
  local d=$(( NOW - $1 ))
  if   [ "$d" -lt 60 ];     then echo "now"
  elif [ "$d" -lt 3600 ];   then echo "$(( d / 60 ))m"
  elif [ "$d" -lt 86400 ];  then echo "$(( d / 3600 ))h"
  elif [ "$d" -lt 2592000 ]; then echo "$(( d / 86400 ))d"
  else echo "$(( d / 2592000 ))mo"
  fi
}

# ── Main: newest first, stop at LIMIT ───────────────────────────────────────────
count=0
find "$PROJECTS_DIR" -mindepth 2 -maxdepth 2 -name '*.jsonl' -print0 2>/dev/null \
  | while IFS= read -r -d '' file; do
      printf '%s\t%s\n' "$(mtime_of "$file")" "$file"
    done \
  | sort -rn \
  | while IFS=$'\t' read -r mtime file; do
      id=$(basename "$file" .jsonl)
      cache="$CACHE_DIR/$id"

      if [ -f "$cache" ] && [ "$(cut -f1 "$cache")" = "$mtime" ]; then
        line=$(cat "$cache")
      else
        line=$(parse_session "$file" "$mtime")
        printf '%s\n' "$line" > "$cache"
      fi

      IFS=$'\t' read -r _ cwd branch title <<< "$line"

      [ -n "$CWD_FILTER" ] && [ "$cwd" != "$CWD_FILTER" ] && continue

      project=$(basename "${cwd:-?}")
      [ -n "$branch" ] && [ "$branch" != "HEAD" ] && project="$project [$branch]"

      printf '%s\t%s\t%s\t%s\n' "$id" "$title" "$(rel_time "$mtime")" "$project"

      count=$(( count + 1 ))
      [ "$LIMIT" -gt 0 ] && [ "$count" -ge "$LIMIT" ] && break
    done
