#!/usr/bin/env bash
#
# tmux-openclaw — tmux plugin for OpenClaw session management
# https://github.com/sergio/tmux-openclaw
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configurable trigger key (default: g)
trigger_key=$(tmux show-option -gqv "@openclaw-trigger-key")
trigger_key="${trigger_key:-g}"

# Register trigger: prefix + <trigger_key> → enter [claw] key table
tmux bind-key -T prefix "$trigger_key" switch-client -T claw

# ── [claw] key table ────────────────────────────────────────────────────────
# g  →  switch CURRENT pane to existing session (fzf picker)
# n  →  new OpenClaw session in a new PANE
# N  →  new OpenClaw session in a new WINDOW
# a  →  attach existing session → picker → open in PANE
# A  →  attach existing session → picker → open in WINDOW
# d  →  dashboard: all sessions in GRID layout (new window)
# v  →  dashboard: all sessions VERTICAL layout (new window)
# h  →  dashboard: all sessions HORIZONTAL layout (new window)

tmux bind-key -T claw g run-shell "$CURRENT_DIR/scripts/switch_session.sh"
tmux bind-key -T claw n run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh pane"
tmux bind-key -T claw N run-shell "$CURRENT_DIR/scripts/prompt_new_session.sh window"
tmux bind-key -T claw a run-shell "$CURRENT_DIR/scripts/attach_session.sh pane"
tmux bind-key -T claw A run-shell "$CURRENT_DIR/scripts/attach_session.sh window"
tmux bind-key -T claw d run-shell "$CURRENT_DIR/scripts/dashboard.sh grid"
tmux bind-key -T claw v run-shell "$CURRENT_DIR/scripts/dashboard.sh vertical"
tmux bind-key -T claw h run-shell "$CURRENT_DIR/scripts/dashboard.sh horizontal"

# Escape [claw] table without doing anything
tmux bind-key -T claw Escape switch-client -T root
