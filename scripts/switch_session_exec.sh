#!/usr/bin/env bash
# Used by display-menu fallback in switch_session.sh
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

SESSION_NAME="$1"
CMD=$(agents_open_cmd "$SESSION_NAME")
tmux respawn-pane -k "$CMD"
tmux select-pane -T "$SESSION_NAME"
