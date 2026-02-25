#!/usr/bin/env bash
#
# attach_session.sh <mode>
# Picks an existing OpenClaw session via fzf and opens it in a new pane or window.
# Popup opens immediately; openclaw fetch happens inside it (no pre-popup delay).
# mode: pane | window

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODE="${1:-pane}"

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
    tmux display-message "tmux-agents: no OpenClaw sessions found"
    exit 1
  fi
  MENU_ARGS=("-T" "#[fg=cyan]OpenClaw Sessions")
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    MENU_ARGS+=("$name" "" "run-shell '$SCRIPTS_DIR/open_session.sh $name $MODE'")
  done <<< "$SESSION_NAMES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  # Check if the session actually exists
  if bash "$SCRIPTS_DIR/get_sessions.sh" | grep -qx "$SELECTED"; then
    bash "$SCRIPTS_DIR/new_session.sh" "$SELECTED" "$MODE"
  else
    # Session not found — offer to create it
    tmux display-menu -T "#[fg=yellow]Session '${SELECTED}' not found" \
      "Create it" "y" "run-shell 'bash \"$SCRIPTS_DIR/new_session.sh\" \"$SELECTED\" \"$MODE\"'" \
      "" \
      "Cancel" "n" ""
  fi
fi
