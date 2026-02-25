#!/usr/bin/env bash
#
# switch_session.sh
# Picks an existing session via fzf and respawns the CURRENT pane with it.
# Popup opens immediately; session fetch happens inside it (no pre-popup delay).

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

CLI_DISPLAY=$(agents_cli_display_name)

if command -v fzf >/dev/null 2>&1; then
  TMPFILE=$(mktemp /tmp/tmux-agents.XXXXXX)
  tmux display-popup -E \
    "bash '$SCRIPTS_DIR/get_sessions.sh' | fzf --prompt='Switch to › ' --border --height=40% > '$TMPFILE'"
  SELECTED=$(cat "$TMPFILE" 2>/dev/null | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: build menu from pre-fetched list
  SESSION_NAMES=$(bash "$SCRIPTS_DIR/get_sessions.sh")
  if [ -z "$SESSION_NAMES" ]; then
    tmux display-message "tmux-agents: no $CLI_DISPLAY sessions found"
    exit 1
  fi
  MENU_ARGS=("-T" "#[fg=cyan]Switch Session")
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    MENU_ARGS+=("$name" "" "run-shell '$SCRIPTS_DIR/switch_session_exec.sh $name'")
  done <<< "$SESSION_NAMES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  CMD=$(agents_open_cmd "$SELECTED")
  tmux respawn-pane -k "$CMD"
  tmux select-pane -T "$SELECTED"
fi
