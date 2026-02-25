#!/usr/bin/env bash
#
# rotate_panes.sh <direction>
# Carousel-rotates all pane contents in the current window.
# direction: forward (default) | backward
# Focus stays on the same screen position.

DIR="${1:-forward}"

# Get all pane IDs in order
mapfile -t PANES < <(tmux list-panes -F "#{pane_id}")

COUNT=${#PANES[@]}
[ "$COUNT" -le 1 ] && exit 0

if [ "$DIR" = "forward" ]; then
  # Shift all content forward: last pane's content ends up in first position
  # Chain swaps from end to start
  for (( i=COUNT-1; i>0; i-- )); do
    tmux swap-pane -d -s "${PANES[$i]}" -t "${PANES[$((i-1))]}"
  done
else
  # Shift all content backward: first pane's content ends up in last position
  for (( i=0; i<COUNT-1; i++ )); do
    tmux swap-pane -d -s "${PANES[$i]}" -t "${PANES[$((i+1))]}"
  done
fi
