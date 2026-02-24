#!/usr/bin/env bash
#
# dashboard_kill.sh — kill the dashboard window

DASH_WIN=$(tmux list-windows -F "#{window_id} #{@openclaw-dashboard}" 2>/dev/null \
  | awk '$2=="1" {print $1}' | head -1)

if [ -z "$DASH_WIN" ]; then
  tmux display-message "tmux-openclaw: no dashboard to kill"
  exit 1
fi

tmux kill-window -t "$DASH_WIN"
