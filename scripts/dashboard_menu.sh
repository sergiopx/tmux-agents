#!/usr/bin/env bash
#
# dashboard_menu.sh — D binding: display-menu for dashboard management

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DASH_WIN=$(tmux list-windows -F "#{window_id} #{@openclaw-dashboard}" 2>/dev/null \
  | awk '$2=="1" {print $1}' | head -1)

if [ -z "$DASH_WIN" ]; then
  # No dashboard — offer to create
  tmux display-menu -T "#[fg=cyan]OpenClaw Dashboard" \
    "Create Dashboard" "" "run-shell '$SCRIPTS_DIR/dashboard.sh'"
  exit 0
fi

tmux display-menu -T "#[fg=cyan]OpenClaw Dashboard" \
  "Hide session"        h "run-shell '$SCRIPTS_DIR/dashboard_hide.sh'" \
  "Show hidden"         u "run-shell '$SCRIPTS_DIR/dashboard_show.sh'" \
  ""                    "" "" \
  "Refresh"             r "run-shell '$SCRIPTS_DIR/dashboard_refresh.sh'" \
  ""                    "" "" \
  "Layout: Grid"        1 "run-shell '$SCRIPTS_DIR/dashboard_relayout.sh tiled'" \
  "Layout: Vertical"    2 "run-shell '$SCRIPTS_DIR/dashboard_relayout.sh even-vertical'" \
  "Layout: Horizontal"  3 "run-shell '$SCRIPTS_DIR/dashboard_relayout.sh even-horizontal'" \
  ""                    "" "" \
  "Kill dashboard"      x "run-shell '$SCRIPTS_DIR/dashboard_kill.sh'"
