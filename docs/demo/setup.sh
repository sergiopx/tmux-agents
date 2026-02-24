#!/usr/bin/env bash
# setup.sh — prepares a clean demo tmux session for VHS recording
# Run this BEFORE the VHS tape. Not recorded.
# Dashboard is triggered automatically after DELAY_SECS (VHS just records it).

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEMO_DIR="$PLUGIN_DIR/docs/demo"
DELAY_SECS="${1:-4}"  # seconds before dashboard auto-opens

# Kill any existing demo session
tmux kill-session -t agents-demo 2>/dev/null

# Create detached session using bash (clean, no powerline)
tmux new-session -d -s agents-demo -x 220 -y 50 \
  -e "PS1=$ " \
  -e "TMUXAGENTS_DEMO_SESSIONS=research,coding,writing,analysis" \
  -e "PATH=$DEMO_DIR:$PATH" \
  bash

# Load the plugin + clean prompt
tmux send-keys -t agents-demo \
  "source '$PLUGIN_DIR/tmux-agents.tmux' && export PS1='$ ' && clear" Enter

sleep 2

# Auto-trigger dashboard after DELAY_SECS (background timer)
(
  sleep "$DELAY_SECS"
  tmux run-shell "$PLUGIN_DIR/scripts/dashboard.sh"
) &

echo "✓ Demo session ready — dashboard opens in ${DELAY_SECS}s"
echo "  Attach: tmux attach-session -t agents-demo"
