#!/usr/bin/env bash
#
# open_session.sh <session-name> <mode>
# Thin wrapper used by display-menu fallback in attach_session.sh

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bash "$SCRIPTS_DIR/new_session.sh" "$1" "${2:-pane}"
