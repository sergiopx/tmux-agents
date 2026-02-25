# Issue #3: Visual Dimming Effect

## Understanding
- tmux-agents is a TPM plugin for managing AI agent sessions
- Dashboard creates tiled panes showing agent sessions
- Need: dim non-focused panes so active pane stands out
- Keybindings use `[agents]` key table, entered via `prefix + g`

## Plan
1. **Create `scripts/dashboard_dim.sh`** — toggle script that:
   - Reads `@tmuxagents-dim` option (default: off)
   - If off → set window-style dim + window-active-style bright, set option to on
   - If on → reset both styles to default, set option to off
2. **Add keybinding** in `tmux-agents.tmux`: `t` → run-shell dashboard_dim.sh
3. **Update README.md** with `t` keybinding and global note

## Completed
All 3 tasks done in single iteration. Commit: 4ec29eb (feat/issue-3-visual-effect).
- Created `scripts/dashboard_dim.sh` — toggle dim on/off via @tmuxagents-dim
- Added `t` keybinding in `tmux-agents.tmux` [agents] key table
- Updated `README.md` — keybinding table + pane dimming section with global note
