#!/usr/bin/env bash
# get_visible_sessions.sh — user sessions minus hidden list
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HIDDEN_FILE="$HOME/.config/tmux-agents/hidden"

while IFS= read -r session; do
  [ -z "$session" ] && continue
  if ! grep -qxF "$session" "$HIDDEN_FILE" 2>/dev/null; then
    echo "$session"
  fi
done < <(bash "$SCRIPTS_DIR/get_sessions.sh")
