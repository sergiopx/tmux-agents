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
  tmux display-popup -E -w 80% -h 60% \
    "bash '$SCRIPTS_DIR/get_sessions.sh' | fzf $AGENTS_FZF_OPTS --prompt='Switch to › ' --border | cut -f1 > '$TMPFILE'"
  SELECTED=$(cat "$TMPFILE" 2>/dev/null | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: build menu from pre-fetched list
  SESSION_LINES=$(bash "$SCRIPTS_DIR/get_sessions.sh")
  if [ -z "$SESSION_LINES" ]; then
    tmux display-message "tmux-agents: no $CLI_DISPLAY sessions found"
    exit 1
  fi
  MENU_ARGS=("-T" "#[fg=cyan]Switch Session")
  while IFS=$'\t' read -r id label _; do
    [ -z "$id" ] && continue
    MENU_ARGS+=("${label:-$id}" "" "run-shell '$SCRIPTS_DIR/open_session.sh $id current'")
  done <<< "$SESSION_LINES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  bash "$SCRIPTS_DIR/open_session.sh" "$SELECTED" current
fi
