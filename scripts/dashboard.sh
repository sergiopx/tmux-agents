#!/usr/bin/env bash
#
# dashboard.sh — go to dashboard (create if not exists, switch if exists)

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ── Detect existing dashboard in current session ─────────────────────────────
DASH_WIN=$(tmux list-windows -F "#{window_id} #{@tmuxagents-dashboard}" 2>/dev/null \
  | awk '$2=="1" {print $1}' | head -1)

if [ -n "$DASH_WIN" ]; then
  tmux select-window -t "$DASH_WIN"
  exit 0
fi

# ── Create dashboard ─────────────────────────────────────────────────────────
mapfile -t SESSIONS < <(bash "$SCRIPTS_DIR/get_visible_sessions.sh")
COUNT=${#SESSIONS[@]}

if [ "$COUNT" -eq 0 ]; then
  tmux display-message "tmux-agents: no sessions to display"
  exit 1
fi

# Apply max limit if configured (0 = no limit)
MAX=$(tmux show-option -gqv "@tmuxagents-dashboard-max")
MAX="${MAX:-0}"
if [ "$MAX" -gt 0 ] 2>/dev/null && [ "$COUNT" -gt "$MAX" ]; then
  SESSIONS=("${SESSIONS[@]:0:$MAX}")
  COUNT=$MAX
fi

DEFAULT_LAYOUT=$(tmux show-option -gqv "@tmuxagents-dashboard-layout")
DEFAULT_LAYOUT="${DEFAULT_LAYOUT:-tiled}"

# Create window + get first pane ID
tmux new-window -n "agents:dash"
DASH_WIN=$(tmux display-message -p "#{window_id}")
PANE_IDS=()
PANE_IDS+=("$(tmux display-message -p '#{pane_id}')")

# Create remaining panes
for (( i=1; i<COUNT; i++ )); do
  NEW_PANE=$(tmux split-window -t "$DASH_WIN" -d -P -F "#{pane_id}")
  PANE_IDS+=("$NEW_PANE")
done

# Apply layout immediately (structure visible now)
tmux select-layout -t "$DASH_WIN" "$DEFAULT_LAYOUT"

# Tag window with dashboard metadata
tmux set-option -wt "$DASH_WIN" @tmuxagents-dashboard 1
tmux set-option -wt "$DASH_WIN" @tmuxagents-dashboard-layout "$DEFAULT_LAYOUT"

# Respawn each pane with openclaw (all load in parallel)
for (( i=0; i<COUNT; i++ )); do
  session="${SESSIONS[$i]}"
  pane="${PANE_IDS[$i]}"
  tmux respawn-pane -k -t "$pane" "openclaw tui --session '$session'"
  tmux set-option -pt "$pane" @tmuxagents-session "$session"
  tmux select-pane -T "$session" -t "$pane"
done
