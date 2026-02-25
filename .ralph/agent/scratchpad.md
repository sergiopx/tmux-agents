# Scratchpad — Issue #1: attach_session.sh create-on-missing

## Understanding
- `attach_session.sh` uses fzf to pick an existing OpenClaw session and opens it via `new_session.sh`
- Problem: if the selected session doesn't actually exist (e.g., race condition — session deleted between fzf listing and selection), the popup closes silently
- Fix: after SELECTED is set, verify the session exists via `get_sessions.sh | grep`. If missing, offer to create via `tmux display-menu`

## Plan
1. Modify `attach_session.sh`: after SELECTED is set (line ~15), check session existence
2. If session doesn't exist → `tmux display-menu` asking "Create it?" (y/n)
3. If yes → call `new_session.sh`; if no → exit
4. Update README to note the create-on-missing behavior for `a`/`A` keys
5. Commit on branch `fix/issue-1-attach-session`

## Key files
- `scripts/attach_session.sh` — main target
- `scripts/get_sessions.sh` — session listing
- `scripts/new_session.sh` — creates session pane/window
- `README.md` — keybinding docs

## Completed
- Implemented session existence check after fzf selection using `get_sessions.sh | grep -qx`
- Added `tmux display-menu` prompt with "Create it" / "Cancel" options when session not found
- Updated README keybinding table to note create-on-missing behavior for `a`/`A` keys
- Committed as `23c783e` on `fix/issue-1-attach-session`, closes #1
