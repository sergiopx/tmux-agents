#!/usr/bin/env bash
#
# attach_session.sh <mode>
# Picks an existing session via fzf and opens it in a new pane or window.
# Popup opens immediately; session fetch happens inside it (no pre-popup delay).
# mode: pane | window

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"
MODE="${1:-pane}"
CLI_DISPLAY=$(agents_cli_display_name)

if command -v fzf >/dev/null 2>&1; then
  TMPFILE=$(mktemp /tmp/tmux-agents.XXXXXX)
  tmux display-popup -E \
    "bash '$SCRIPTS_DIR/get_sessions.sh' | fzf --prompt='Attach › ' --border --height=40% > '$TMPFILE'"
  SELECTED=$(cat "$TMPFILE" 2>/dev/null | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: build menu from pre-fetched list
  SESSION_NAMES=$(bash "$SCRIPTS_DIR/get_sessions.sh")
  if [ -z "$SESSION_NAMES" ]; then
    tmux display-message "tmux-agents: no $CLI_DISPLAY sessions found"
    exit 1
  fi
  MENU_ARGS=("-T" "#[fg=cyan]$CLI_DISPLAY Sessions")
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    MENU_ARGS+=("$name" "" "run-shell '$SCRIPTS_DIR/open_session.sh $name $MODE'")
  done <<< "$SESSION_NAMES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  bash "$SCRIPTS_DIR/new_session.sh" "$SELECTED" "$MODE"
fi
