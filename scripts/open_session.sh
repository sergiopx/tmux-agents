#!/usr/bin/env bash
#
# open_session.sh <session-id> <mode>
# Opens (resumes) an EXISTING session in a new pane, window, or the current pane.
# mode: pane | window | current
#
# For brand-new sessions use new_session.sh instead.

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

SESSION_ID="$(echo "${1:-}" | xargs)"
MODE="${2:-pane}"

if [ -z "$SESSION_ID" ]; then
  tmux display-message "tmux-agents: no session given"
  exit 1
fi

CMD=$(agents_open_cmd "$SESSION_ID")
LABEL=$(agents_session_label "$SESSION_ID")

if [ "$MODE" = "window" ]; then
  tmux new-window -n "$LABEL" "$CMD"
elif [ "$MODE" = "current" ]; then
  tmux respawn-pane -k "$CMD"
  tmux select-pane -T "$LABEL"
else
  split_dir=$(tmux show-option -gqv "@tmuxagents-split-direction")
  split_dir="${split_dir:-h}"
  if [ "$split_dir" = "v" ]; then
    tmux split-window -v "$CMD"
  else
    tmux split-window -h "$CMD"
  fi
  tmux select-pane -T "$LABEL"
fi
