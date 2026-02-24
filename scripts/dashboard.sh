#!/usr/bin/env bash
#
# dashboard.sh <layout>
# Opens all user OpenClaw sessions in a new tmux window.
# Strategy: create ALL panes first → apply layout → respawn each with openclaw.
# This makes the visual structure appear immediately while sessions load in parallel.
#
# layout: grid | vertical | horizontal

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LAYOUT="${1:-grid}"

# Fetch sessions (1.5s Node.js startup — unavoidable here since we need count)
mapfile -t SESSIONS < <(bash "$SCRIPTS_DIR/get_sessions.sh")

COUNT=${#SESSIONS[@]}

if [ "$COUNT" -eq 0 ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 1
fi

# ── Step 1: Create pane skeleton instantly ───────────────────────────────────

tmux new-window -n "claw:$LAYOUT"

PANE_IDS=()
PANE_IDS+=("$(tmux display-message -p '#{pane_id}')")

for (( i=1; i<COUNT; i++ )); do
  tmux split-window -d   # -d = don't focus new pane
  PANE_IDS+=("$(tmux display-message -p '#{pane_id}')")
done

# ── Step 2: Apply layout (grid is visible immediately) ───────────────────────

case "$LAYOUT" in
  vertical)   tmux select-layout even-vertical ;;
  horizontal) tmux select-layout even-horizontal ;;
  grid)       tmux select-layout tiled ;;
esac

# ── Step 3: Respawn each pane with openclaw (all load in parallel) ────────────

for (( i=0; i<COUNT; i++ )); do
  session="${SESSIONS[$i]}"
  pane="${PANE_IDS[$i]}"
  tmux respawn-pane -k -t "$pane" "openclaw tui --session '$session'"
  tmux select-pane -T "$session" -t "$pane"
done
