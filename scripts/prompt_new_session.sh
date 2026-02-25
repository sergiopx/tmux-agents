#!/usr/bin/env bash
#
# prompt_new_session.sh <mode>
# Prompts for a session name then opens a new pane/window/current pane.
# For CLIs that don't support named sessions, launches directly.
# mode: pane | window | current

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"
MODE="${1:-pane}"

if agents_supports_named_sessions; then
  # CLI supports named sessions — prompt for a name
  DEFAULT=$(agents_next_default_name)
  tmux command-prompt -p "Session name:" -I "$DEFAULT" \
    "run-shell '$SCRIPTS_DIR/new_session.sh %% $MODE'"
else
  # CLI manages session IDs internally — launch directly
  "$SCRIPTS_DIR/new_session.sh" "" "$MODE"
fi
