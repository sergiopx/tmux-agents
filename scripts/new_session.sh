#!/usr/bin/env bash
#
# new_session.sh <session-name> <mode>
# Opens openclaw tui in a new pane or window.
# mode: pane | window

SESSION_NAME="${1:-agent}"
MODE="${2:-pane}"

# Strip whitespace
SESSION_NAME="$(echo "$SESSION_NAME" | xargs)"

if [ -z "$SESSION_NAME" ]; then
  tmux display-message "tmux-agents: session name cannot be empty"
  exit 1
fi

CMD="openclaw tui --session '$SESSION_NAME'"

if [ "$MODE" = "window" ]; then
  tmux new-window -n "$SESSION_NAME" "$CMD"
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
