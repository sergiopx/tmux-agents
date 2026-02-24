#!/usr/bin/env bash
#
# dashboard.sh <layout>
# Opens all user OpenClaw sessions in a new tmux window.
# layout: grid (tiled) | vertical (even-vertical)

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAYOUT="${1:-grid}"

SESSIONS=$(bash "$SCRIPTS_DIR/get_sessions.sh")

if [ -z "$SESSIONS" ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 1
fi

FIRST=true
while IFS= read -r session; do
  [ -z "$session" ] && continue
  if $FIRST; then
    tmux new-window -n "claw:$LAYOUT" "openclaw tui --session '$session'"
    tmux select-pane -T "$session"
    FIRST=false
  else
    tmux split-window "openclaw tui --session '$session'"
    tmux select-pane -T "$session"
  fi
done <<< "$SESSIONS"

# Apply layout
case "$LAYOUT" in
  vertical) tmux select-layout even-vertical ;;
  grid)     tmux select-layout tiled ;;
esac
