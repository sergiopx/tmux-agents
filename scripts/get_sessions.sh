#!/usr/bin/env bash
# get_sessions.sh — prints user OpenClaw session names, one per line
# Demo mode: set TMUXAGENTS_DEMO_SESSIONS="research,coding,writing,analysis"
if [ -n "$TMUXAGENTS_DEMO_SESSIONS" ]; then
  echo "$TMUXAGENTS_DEMO_SESSIONS" | tr ',' '\n'
  exit 0
fi

openclaw sessions --json 2>/dev/null \
  | jq -r '.sessions[] | .key | sub("agent:main:"; "") | select(test(":") | not)'
