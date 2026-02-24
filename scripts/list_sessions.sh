#!/usr/bin/env bash
#
# list_sessions.sh
# Shows all OpenClaw sessions in a popup (name, last updated, tokens).

OUTPUT=$(openclaw sessions 2>/dev/null)

if [ -z "$OUTPUT" ]; then
  tmux display-message "tmux-openclaw: no OpenClaw sessions found"
  exit 0
fi

tmux display-popup -E -w 80 -h 20 \
  "echo $(printf '%q' "$OUTPUT") | less -S"
