#!/usr/bin/env bash
#
# new_session.sh <session-name> <mode>
# Opens a CLI session in a new pane, window, or current pane.
# mode: pane | window | current

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

SESSION_NAME="${1:-agent}"
MODE="${2:-pane}"

# Strip whitespace
SESSION_NAME="$(echo "$SESSION_NAME" | xargs)"

if [ -z "$SESSION_NAME" ]; then
  tmux display-message "tmux-agents: session name cannot be empty"
  exit 1
fi

CMD=$(agents_new_cmd "$SESSION_NAME")

if [ "$MODE" = "window" ]; then
  tmux new-window -n "$SESSION_NAME" "$CMD"
elif [ "$MODE" = "current" ]; then
  tmux respawn-pane -k "$CMD"
  tmux select-pane -T "$SESSION_NAME"
else
  # Respect user split direction preference (h=horizontal[default], v=vertical)
  split_dir=$(tmux show-option -gqv "@tmuxagents-split-direction")
  split_dir="${split_dir:-h}"

  if [ "$split_dir" = "v" ]; then
    tmux split-window -v "$CMD"
  else
    tmux split-window -h "$CMD"
  fi
  tmux select-pane -T "$SESSION_NAME"
fi
