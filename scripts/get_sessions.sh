#!/usr/bin/env bash
# get_sessions.sh — prints user OpenClaw session names, one per line
openclaw sessions --json 2>/dev/null \
  | jq -r '.sessions[] | .key | sub("agent:main:"; "") | select(test(":") | not)'
