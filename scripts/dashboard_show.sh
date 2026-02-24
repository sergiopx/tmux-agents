#!/usr/bin/env bash
#
# dashboard_show.sh — fzf pick a hidden session → remove from hidden list

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_DIR="$HOME/.config/tmux-openclaw"
HIDDEN_FILE="$CONFIG_DIR/hidden"

if [ ! -f "$HIDDEN_FILE" ] || [ ! -s "$HIDDEN_FILE" ]; then
  tmux display-message "tmux-openclaw: no hidden sessions"
  exit 0
fi

TMPFILE_DATA=$(mktemp /tmp/tmux-openclaw.XXXXXX)
cat "$HIDDEN_FILE" > "$TMPFILE_DATA"

TMPFILE_OUT=$(mktemp /tmp/tmux-openclaw.XXXXXX)
tmux display-popup -E \
  "cat '$TMPFILE_DATA' | fzf --prompt='Show › ' --border --height=40% > '$TMPFILE_OUT'"

SELECTED=$(cat "$TMPFILE_OUT" 2>/dev/null | xargs)
rm -f "$TMPFILE_DATA" "$TMPFILE_OUT"

if [ -n "$SELECTED" ]; then
  grep -vxF "$SELECTED" "$HIDDEN_FILE" > "$HIDDEN_FILE.tmp" \
    && mv "$HIDDEN_FILE.tmp" "$HIDDEN_FILE"
  bash "$SCRIPTS_DIR/dashboard_refresh.sh"
fi
