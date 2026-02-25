#!/usr/bin/env bash
#
# dashboard_dim.sh — toggle dimming of inactive panes
#
# Dims non-focused panes so the active pane stands out.
# State stored in @tmuxagents-dim (on/off, default off).
#
# Uses a hook-based approach: installs an after-select-pane hook
# that calls dashboard_dim_apply.sh to style each pane individually.

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APPLY_SCRIPT="$CURRENT_DIR/dashboard_dim_apply.sh"

current=$(tmux show-option -gqv "@tmuxagents-dim")
current="${current:-off}"

if [ "$current" = "off" ]; then
  # Turn dimming ON
  tmux set-option -g @tmuxagents-dim "on"

  # Install hook: re-apply dim styling whenever a pane is selected
  tmux set-hook -g after-select-pane[99] "run-shell '$APPLY_SCRIPT'"

  # Apply immediately
  bash "$APPLY_SCRIPT"

  tmux display-message "tmux-agents: pane dimming ON"
else
  # Turn dimming OFF
  tmux set-option -g @tmuxagents-dim "off"

  # Remove the hook
  tmux set-hook -gu after-select-pane[99]

  # Reset all pane styles to default
  while IFS=' ' read -r pane_id _; do
    tmux select-pane -t "$pane_id" -P "default"
  done < <(tmux list-panes -F "#{pane_id} #{pane_active}")

  tmux display-message "tmux-agents: pane dimming OFF"
fi
