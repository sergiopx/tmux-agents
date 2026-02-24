#!/usr/bin/env bash
#
# dashboard_relayout.sh <layout> — change dashboard layout and save it

LAYOUT="${1:-tiled}"

DASH_WIN=$(tmux list-windows -F "#{window_id} #{@openclaw-dashboard}" 2>/dev/null \
  | awk '$2=="1" {print $1}' | head -1)

if [ -z "$DASH_WIN" ]; then
  tmux display-message "tmux-agents: no dashboard to relayout"
  exit 1
fi

tmux select-layout -t "$DASH_WIN" "$LAYOUT"
tmux set-option -wt "$DASH_WIN" @openclaw-dashboard-layout "$LAYOUT"
