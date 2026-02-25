#!/usr/bin/env bash
#
# prompt_new_session.sh <mode>
# Prompts for a session name then opens a new pane/window/current pane.
# mode: pane | window | current

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODE="${1:-pane}"

# Compute next available agent-N default
NEXT=$(openclaw sessions --json 2>/dev/null \
  | jq '[.sessions[].key | sub("agent:main:"; "") | select(test(":") | not) | select(test("^agent-[0-9]+$"))] | length + 1' \
  2>/dev/null)
[ -z "$NEXT" ] && NEXT=1
DEFAULT="agent-$NEXT"

# Show prompt with default, then call new_session.sh with the result
tmux command-prompt -p "Session name:" -I "$DEFAULT" \
  "run-shell '$SCRIPTS_DIR/new_session.sh %% $MODE'"
