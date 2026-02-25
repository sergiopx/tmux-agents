#!/usr/bin/env bash
#
# dashboard_refresh.sh — sync dashboard panes with current visible sessions
# Additive + subtractive: adds new sessions, removes hidden/deleted ones.

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

DASH_WIN=$(tmux list-windows -F "#{window_id} #{@tmuxagents-dashboard}" 2>/dev/null \
  | awk '$2=="1" {print $1}' | head -1)

if [ -z "$DASH_WIN" ]; then
  tmux display-message "tmux-agents: no dashboard to refresh"
  exit 1
fi

# Get target sessions
mapfile -t VISIBLE < <(bash "$SCRIPTS_DIR/get_visible_sessions.sh")

# Get current pane → session mapping (via @tmuxagents-session pane option)
declare -A SESSION_TO_PANE
declare -A PANE_TO_SESSION

while IFS=' ' read -r pane_id session_name; do
  [ -z "$session_name" ] && continue
  PANE_TO_SESSION["$pane_id"]="$session_name"
  SESSION_TO_PANE["$session_name"]="$pane_id"
done < <(tmux list-panes -t "$DASH_WIN" -F "#{pane_id} #{@tmuxagents-session}" 2>/dev/null)

# ── Remove panes for sessions no longer visible ───────────────────────────────
for pane_id in "${!PANE_TO_SESSION[@]}"; do
  session="${PANE_TO_SESSION[$pane_id]}"
  if ! printf '%s\n' "${VISIBLE[@]}" | grep -qxF "$session"; then
    PANE_COUNT=$(tmux list-panes -t "$DASH_WIN" 2>/dev/null | wc -l)
    if [ "$PANE_COUNT" -gt 1 ]; then
      tmux kill-pane -t "$pane_id"
    fi
  fi
done

# ── Add panes for new visible sessions ───────────────────────────────────────
for session in "${VISIBLE[@]}"; do
  if [ -z "${SESSION_TO_PANE[$session]}" ]; then
    NEW_PANE=$(tmux split-window -t "$DASH_WIN" -d -P -F "#{pane_id}")
    tmux respawn-pane -k -t "$NEW_PANE" "$(agents_open_cmd "$session")"
    tmux set-option -pt "$NEW_PANE" @tmuxagents-session "$session"
    tmux select-pane -T "$session" -t "$NEW_PANE"
  fi
done

# ── Reapply layout ────────────────────────────────────────────────────────────
LAYOUT=$(tmux show-option -wqv -t "$DASH_WIN" @tmuxagents-dashboard-layout 2>/dev/null)
LAYOUT="${LAYOUT:-tiled}"
tmux select-layout -t "$DASH_WIN" "$LAYOUT"

tmux display-message "tmux-agents: dashboard refreshed"
