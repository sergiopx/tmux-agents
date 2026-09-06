#!/usr/bin/env bash
#
# dashboard_hide.sh — fzf pick a visible session → add to hidden list

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"
CONFIG_DIR="$HOME/.config/tmux-agents"
HIDDEN_FILE="$CONFIG_DIR/hidden"

mkdir -p "$CONFIG_DIR"

TMPFILE_DATA=$(mktemp /tmp/tmux-agents.XXXXXX)
bash "$SCRIPTS_DIR/get_visible_sessions.sh" > "$TMPFILE_DATA"

if [ ! -s "$TMPFILE_DATA" ]; then
  rm -f "$TMPFILE_DATA"
  tmux display-message "tmux-agents: no visible sessions to hide"
  exit 0
fi

TMPFILE_OUT=$(mktemp /tmp/tmux-agents.XXXXXX)
tmux display-popup -E \
  "cat '$TMPFILE_DATA' | fzf $AGENTS_FZF_OPTS --prompt='Hide › ' --border --height=40% | cut -f1 > '$TMPFILE_OUT'"

SELECTED=$(cat "$TMPFILE_OUT" 2>/dev/null | xargs)
rm -f "$TMPFILE_DATA" "$TMPFILE_OUT"

if [ -n "$SELECTED" ]; then
  echo "$SELECTED" >> "$HIDDEN_FILE"
  sort -u "$HIDDEN_FILE" -o "$HIDDEN_FILE"
  bash "$SCRIPTS_DIR/dashboard_refresh.sh"
fi
