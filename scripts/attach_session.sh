#!/usr/bin/env bash
#
# attach_session.sh <mode>
# Picks an existing session via fzf and resumes it in a new pane or window.
# Popup opens immediately; session fetch happens inside it (no pre-popup delay).
# mode: pane | window

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"
MODE="${1:-pane}"
CLI_DISPLAY=$(agents_cli_display_name)

if command -v fzf >/dev/null 2>&1; then
  TMPFILE=$(mktemp /tmp/tmux-agents.XXXXXX)
  # --print-query: first line is what was typed, second (if any) the chosen row.
  # Lets the user type a new name and create it when nothing matches.
  tmux display-popup -E -w 80% -h 60% \
    "bash '$SCRIPTS_DIR/get_sessions.sh' | fzf $AGENTS_FZF_OPTS --print-query --prompt='Attach › ' --border > '$TMPFILE'"
  QUERY=$(sed -n 1p "$TMPFILE" 2>/dev/null | xargs)
  SELECTED=$(sed -n 2p "$TMPFILE" 2>/dev/null | cut -f1 | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: build menu from pre-fetched list
  SESSION_LINES=$(bash "$SCRIPTS_DIR/get_sessions.sh")
  if [ -z "$SESSION_LINES" ]; then
    tmux display-message "tmux-agents: no $CLI_DISPLAY sessions found"
    exit 1
  fi
  MENU_ARGS=("-T" "#[fg=cyan]$CLI_DISPLAY Sessions")
  while IFS=$'\t' read -r id label _; do
    [ -z "$id" ] && continue
    MENU_ARGS+=("${label:-$id}" "" "run-shell '$SCRIPTS_DIR/open_session.sh $id $MODE'")
  done <<< "$SESSION_LINES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  # Existing session → resume it
  bash "$SCRIPTS_DIR/open_session.sh" "$SELECTED" "$MODE"
elif [ -n "$QUERY" ]; then
  # Nothing matched what was typed → offer to create a new session with that name
  tmux display-menu -T "#[fg=yellow]No session matches '${QUERY}'" \
    "Create new session" "y" "run-shell 'bash \"$SCRIPTS_DIR/new_session.sh\" \"$QUERY\" \"$MODE\"'" \
    "" \
    "Cancel" "n" ""
fi
