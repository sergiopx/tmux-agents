#!/usr/bin/env bash
#
# prompt_new_session.sh <mode>
# Prompts for a session name then opens a new pane/window.
# mode: pane | window

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MODE="${1:-pane}"

# Compute next available claw-N default
NEXT=$(openclaw sessions --json 2>/dev/null \
  | jq '[.sessions[].key | select(test("agent:main:claw-[0-9]+$"))] | length + 1' \
  2>/dev/null)
[ -z "$NEXT" ] && NEXT=1
DEFAULT="claw-$NEXT"

# Show prompt with default, then call new_session.sh with the result
tmux command-prompt -p "Session name:" -I "$DEFAULT" \
  "run-shell '$SCRIPTS_DIR/new_session.sh %% $MODE'"
