#!/usr/bin/env bash
#
# attach_session.sh <mode>
# Lists OpenClaw sessions via fzf popup (or display-menu fallback),
# then opens the selected session in a new pane or window.
# mode: pane | window

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODE="${1:-pane}"

# Fetch session names (strip "agent:main:" prefix)
SESSIONS_JSON=$(openclaw sessions --json 2>/dev/null)
if [ -z "$SESSIONS_JSON" ]; then
  tmux display-message "tmux-openclaw: openclaw not found or not running"
  exit 1
fi

SESSION_NAMES=$(echo "$SESSIONS_JSON" \
  | jq -r '.sessions[] | .key | sub("agent:main:"; "")' 2>/dev/null)

if [ -z "$SESSION_NAMES" ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 1
fi

# ── Picker ──────────────────────────────────────────────────────────────────

if command -v fzf >/dev/null 2>&1; then
  # fzf via display-popup: write selection to tmpfile
  TMPFILE=$(mktemp /tmp/tmux-openclaw.XXXXXX)
  tmux display-popup -E \
    "echo $(printf '%q' "$SESSION_NAMES") | tr ' ' '\n' | fzf --prompt='OpenClaw › ' --height=40% --border > $(printf '%q' "$TMPFILE")"
  SELECTED=$(cat "$TMPFILE" 2>/dev/null | xargs)
  rm -f "$TMPFILE"
else
  # Fallback: tmux display-menu (no fzf needed)
  MENU_ARGS=("-T" "#[fg=cyan]OpenClaw Sessions")
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    MENU_ARGS+=("$name" "" "run-shell '$SCRIPTS_DIR/open_session.sh $name $MODE'")
  done <<< "$SESSION_NAMES"
  tmux display-menu "${MENU_ARGS[@]}"
  exit 0
fi

# ── Open selected session ────────────────────────────────────────────────────

if [ -n "$SELECTED" ]; then
  bash "$SCRIPTS_DIR/new_session.sh" "$SELECTED" "$MODE"
fi
