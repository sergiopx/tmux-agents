#!/usr/bin/env bash
#
# tmux-agents — tmux plugin for AI CLI session management
# https://github.com/sergiopx/tmux-agents
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configurable trigger key (default: a)
trigger_key=$(tmux show-option -gqv "@tmuxagents-trigger-key")
trigger_key="${trigger_key:-a}"

# Register trigger: prefix + <trigger_key> → enter [agents] key table
tmux bind-key -T prefix "$trigger_key" switch-client -T agents

# ── [agents] key table ──────────────────────────────────────────────────────────
# p  →  attach existing session → picker → open in PANE (offers to create if not found)
# P  →  new session in a new PANE (prompt for name if supported)
# w  →  attach existing session → picker → open in WINDOW (offers to create if not found)
# W  →  new session in a new WINDOW (prompt for name if supported)
# a  →  fzf: switch CURRENT PANE to existing session (respawn in-place)
# A  →  new session in CURRENT PANE (prompt for name, respawn in-place)
# d  →  dashboard: switch to it (create if not exists)
# D  →  dashboard menu: hide/show/refresh/relayout/kill

tmux bind-key -T agents p run-shell "$CURRENT_DIR/scripts/attach_session.sh pane"
tmux bind-key -T agents P run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh pane"
tmux bind-key -T agents w run-shell "$CURRENT_DIR/scripts/attach_session.sh window"
tmux bind-key -T agents W run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh window"
tmux bind-key -T agents a run-shell "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key -T agents A run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh current"
tmux bind-key -T agents d run-shell "$CURRENT_DIR/scripts/dashboard.sh"
tmux bind-key -T agents D run-shell "$CURRENT_DIR/scripts/dashboard_menu.sh"
tmux bind-key -T agents r run-shell "$CURRENT_DIR/scripts/rotate_panes.sh forward"
tmux bind-key -T agents R run-shell "$CURRENT_DIR/scripts/rotate_panes.sh backward"
tmux bind-key -T agents o select-pane -t :.+
tmux bind-key -T agents t run-shell "$CURRENT_DIR/scripts/dashboard_dim.sh"

# Escape [agents] table without doing anything
tmux bind-key -T agents Escape switch-client -T root
