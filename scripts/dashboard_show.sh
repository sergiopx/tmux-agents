#!/usr/bin/env bash
#
# dashboard_show.sh — fzf pick a hidden session → remove from hidden list

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"
CONFIG_DIR="$HOME/.config/tmux-agents"
HIDDEN_FILE="$CONFIG_DIR/hidden"

if [ ! -f "$HIDDEN_FILE" ] || [ ! -s "$HIDDEN_FILE" ]; then
  tmux display-message "tmux-agents: no hidden sessions"
  exit 0
fi

# Hidden ids → labeled lines (fall back to the id when the session is gone)
TMPFILE_DATA=$(mktemp /tmp/tmux-agents.XXXXXX)
ALL=$(bash "$SCRIPTS_DIR/get_sessions.sh")
while IFS= read -r id; do
  [ -z "$id" ] && continue
  line=$(printf '%s\n' "$ALL" | awk -F'\t' -v id="$id" '$1 == id { print; exit }')
  printf '%s\n' "${line:-$id	$id}"
done < "$HIDDEN_FILE" > "$TMPFILE_DATA"

TMPFILE_OUT=$(mktemp /tmp/tmux-agents.XXXXXX)
tmux display-popup -E \
  "cat '$TMPFILE_DATA' | fzf $AGENTS_FZF_OPTS --prompt='Show › ' --border --height=40% | cut -f1 > '$TMPFILE_OUT'"

SELECTED=$(cat "$TMPFILE_OUT" 2>/dev/null | xargs)
rm -f "$TMPFILE_DATA" "$TMPFILE_OUT"

if [ -n "$SELECTED" ]; then
  grep -vxF "$SELECTED" "$HIDDEN_FILE" > "$HIDDEN_FILE.tmp" \
    && mv "$HIDDEN_FILE.tmp" "$HIDDEN_FILE"
  bash "$SCRIPTS_DIR/dashboard_refresh.sh"
fi
