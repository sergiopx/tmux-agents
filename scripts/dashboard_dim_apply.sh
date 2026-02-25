#!/usr/bin/env bash
#
# dashboard_dim_apply.sh — apply dim styling to inactive panes
#
# Called by the after-select-pane hook (installed by dashboard_dim.sh).
# Iterates all panes in the current window:
#   - active pane  → fg=default (bright)
#   - other panes  → fg=colour245 (dimmed)
#

while IFS=' ' read -r pane_id pane_active; do
  if [ "$pane_active" = "1" ]; then
    tmux select-pane -t "$pane_id" -P "fg=default"
  else
    tmux select-pane -t "$pane_id" -P "fg=colour245"
  fi
done < <(tmux list-panes -F "#{pane_id} #{pane_active}")
