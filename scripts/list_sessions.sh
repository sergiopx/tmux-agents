#!/usr/bin/env bash
#
# list_sessions.sh
# Shows all OpenClaw sessions in a popup (name, last updated, tokens).

OUTPUT=$(openclaw sessions --json 2>/dev/null \
  | jq -r '.sessions[] | select(.key | sub("agent:main:"; "") | test(":") | not)
    | "\(.key | sub("agent:main:"; ""))\t\(.totalTokens // 0)tok\t\(.model // "?")"' \
  2>/dev/null)

if [ -z "$OUTPUT" ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 0
fi

tmux display-popup -E -w 60 -h 20 \
  "echo $(printf '%q' "$OUTPUT") | column -t -s $'\t'"
