#!/usr/bin/env bash
# get_visible_sessions.sh — session lines (<id> TAB <label> ...) minus hidden ids
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HIDDEN_FILE="$HOME/.config/tmux-agents/hidden"

while IFS= read -r line; do
  [ -z "$line" ] && continue
  id="${line%%$'\t'*}"
  if ! grep -qxF "$id" "$HIDDEN_FILE" 2>/dev/null; then
    echo "$line"
  fi
done < <(bash "$SCRIPTS_DIR/get_sessions.sh")
