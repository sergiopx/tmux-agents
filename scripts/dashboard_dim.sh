#!/usr/bin/env bash
#
# dashboard_dim.sh — toggle dimming of inactive panes
#
# Dims non-focused panes so the active pane stands out.
# State stored in @tmuxagents-dim (on/off, default off).
#
# NOTE: This uses tmux global window-style / window-active-style,
# which affects ALL panes across ALL windows (tmux limitation).

current=$(tmux show-option -gqv "@tmuxagents-dim")
current="${current:-off}"

if [ "$current" = "off" ]; then
  tmux set-option -g window-style "fg=colour245,bg=default"
  tmux set-option -g window-active-style "fg=colour255,bg=default"
  tmux set-option -g @tmuxagents-dim "on"
  tmux display-message "tmux-agents: pane dimming ON (global)"
else
  tmux set-option -g window-style "default"
  tmux set-option -g window-active-style "default"
  tmux set-option -g @tmuxagents-dim "off"
  tmux display-message "tmux-agents: pane dimming OFF"
fi
