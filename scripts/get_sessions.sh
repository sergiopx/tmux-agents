#!/usr/bin/env bash
# get_sessions.sh — prints sessions, one per line: <id> TAB <label> [TAB ...]
# Dispatches to the configured CLI via cli_adapter.sh
# Demo mode: set TMUXAGENTS_DEMO_SESSIONS="research,coding,writing,analysis"

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPTS_DIR/cli_adapter.sh"

if [ -n "$TMUXAGENTS_DEMO_SESSIONS" ]; then
  echo "$TMUXAGENTS_DEMO_SESSIONS" | tr ',' '\n' | awk 'NF { print $1 "\t" $1 }'
  exit 0
fi

agents_list_sessions
