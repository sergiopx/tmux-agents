#!/usr/bin/env bash
#
# tmux-agents — tmux plugin for OpenClaw session management
# https://github.com/sergiopx/tmux-agents
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configurable trigger key (default: g)
trigger_key=$(tmux show-option -gqv "@openclaw-trigger-key")
trigger_key="${trigger_key:-g}"

# Register trigger: prefix + <trigger_key> → enter [claw] key table
tmux bind-key -T prefix "$trigger_key" switch-client -T claw

# ── [claw] key table ────────────────────────────────────────────────────────
# g  →  fzf: switch CURRENT PANE to existing session (respawn in-place)
# n  →  new OpenClaw session in a new PANE (prompt for name)
# N  →  new OpenClaw session in a new WINDOW (prompt for name)
# a  →  attach existing session → picker → open in PANE
# A  →  attach existing session → picker → open in WINDOW
# d  →  dashboard: switch to it (create if not exists)
# D  →  dashboard menu: hide/show/refresh/relayout/kill

tmux bind-key -T claw g run-shell "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key -T claw n run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh pane"
tmux bind-key -T claw N run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh window"
tmux bind-key -T claw a run-shell "$CURRENT_DIR/scripts/attach_session.sh pane"
tmux bind-key -T claw A run-shell "$CURRENT_DIR/scripts/attach_session.sh window"
tmux bind-key -T claw d run-shell "$CURRENT_DIR/scripts/dashboard.sh"
tmux bind-key -T claw D run-shell "$CURRENT_DIR/scripts/dashboard_menu.sh"

# Escape [claw] table without doing anything
tmux bind-key -T claw Escape switch-client -T root
