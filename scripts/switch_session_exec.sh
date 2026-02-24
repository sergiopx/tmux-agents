#!/usr/bin/env bash
# Used by display-menu fallback in switch_session.sh
SESSION_NAME="$1"
tmux respawn-pane -k "openclaw tui --session '$SESSION_NAME'"
tmux select-pane -T "$SESSION_NAME"
