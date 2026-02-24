#!/usr/bin/env bash
#
# switch_session.sh
# Picks an existing OpenClaw session via fzf and respawns the CURRENT pane with it.

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

SESSIONS_JSON=$(openclaw sessions --json 2>/dev/null)
if [ -z "$SESSIONS_JSON" ]; then
  tmux display-message "tmux-openclaw: openclaw not found or not running"
  exit 1
fi

SESSION_NAMES=$(echo "$SESSIONS_JSON" \
  | jq -r '.sessions[] | .key | sub("agent:main:"; "") | select(test(":") | not)' 2>/dev/null)

if [ -z "$SESSION_NAMES" ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 1
fi

if command -v fzf >/dev/null 2>&1; then
  TMPFILE=$(mktemp /tmp/tmux-openclaw.XXXXXX)
  tmux display-popup -E \
    "echo $(printf '%q' "$SESSION_NAMES") | tr ' ' '\n' | fzf --prompt='Switch to › ' --height=40% --border > $(printf '%q' "$TMPFILE")"
  SELECTED=$(cat "$TMPFILE" 2>/dev/null | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: display-menu
  MENU_ARGS=("-T" "#[fg=cyan]Switch Session")
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    MENU_ARGS+=("$name" "" "run-shell '$SCRIPTS_DIR/switch_session_exec.sh $name'")
  done <<< "$SESSION_NAMES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

if [ -n "$SELECTED" ]; then
  # Respawn current pane in-place with the selected session
  tmux respawn-pane -k "openclaw tui --session '$SELECTED'"
  tmux select-pane -T "$SELECTED"
fi
