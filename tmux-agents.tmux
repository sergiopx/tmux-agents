#!/usr/bin/env bash
#
# tmux-agents — tmux plugin for AI CLI session management
# https://github.com/sergiopx/tmux-agents
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configurable trigger key (default: g)
trigger_key=$(tmux show-option -gqv "@tmuxagents-trigger-key")
trigger_key="${trigger_key:-g}"

# Register trigger: prefix + <trigger_key> → enter [agents] key table
tmux bind-key -T prefix "$trigger_key" switch-client -T agents

# ── [agents] key table ──────────────────────────────────────────────────────────
# g  →  fzf: switch CURRENT PANE to existing session (respawn in-place)
# n  →  new session in a new PANE (prompt for name if supported)
# N  →  new session in a new WINDOW (prompt for name if supported)
# a  →  attach existing session → picker → open in PANE
# A  →  attach existing session → picker → open in WINDOW
# d  →  dashboard: switch to it (create if not exists)
# D  →  dashboard menu: hide/show/refresh/relayout/kill

tmux bind-key -T agents g run-shell "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key -T agents n run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh pane"
tmux bind-key -T agents N run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh window"
tmux bind-key -T agents a run-shell "$CURRENT_DIR/scripts/attach_session.sh pane"
tmux bind-key -T agents A run-shell "$CURRENT_DIR/scripts/attach_session.sh window"
tmux bind-key -T agents d run-shell "$CURRENT_DIR/scripts/dashboard.sh"
tmux bind-key -T agents D run-shell "$CURRENT_DIR/scripts/dashboard_menu.sh"

# Escape [agents] table without doing anything
tmux bind-key -T agents Escape switch-client -T root
