# Issue #4: Multi-CLI Support

## Research Summary

All 4 CLIs are installed. Here's what I found:

### OpenClaw (current)
- List: `openclaw sessions --json | jq -r '...'`
- Open/resume: `openclaw tui --session '<name>'`
- Sessions are human-named (e.g., "agent-1")

### Claude Code
- List: No clean CLI subcommand. Sessions stored as `~/.claude/projects/<project-hash>/<uuid>.jsonl`. Can use `claude --resume` for interactive picker.
- Resume: `claude --resume <session-id>`
- Continue last: `claude --continue`
- New: `claude` (just launch)
- Sessions are UUID-based, not human-named. Limited session listing from CLI.
- Note: `CLAUDECODE` env var must be unset to avoid nesting error.

### OpenCode
- List: `opencode session list` (exists but returned empty in test - may need active sessions)
- Resume: `opencode --session <id>` or `opencode -c` (continue last)
- New: `opencode` (just launch)

### Codex
- List: `codex resume --all` (needs a terminal, won't work in non-interactive). Sessions stored in `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`
- Resume: `codex resume <session-id>` or `codex resume --last`
- New: `codex` (just launch)
- Session names contain timestamps and UUIDs

### Gemini
- List: `gemini --list-sessions` (works! project-scoped)
- Resume: `gemini --resume <index>` or `gemini --resume latest`
- New: `gemini` (just launch)

## Architecture Decision

Create `scripts/cli_adapter.sh` with functions:
1. `agents_cli_name` — returns configured CLI name from `@tmuxagents-cli`
2. `agents_list_sessions` — lists sessions one per line
3. `agents_open_cmd <session>` — returns the command string to open/resume a session
4. `agents_new_cmd` — returns the command to start a new session (no session name)
5. `agents_next_default_name` — returns next default session name

All existing scripts will source `cli_adapter.sh` and use these functions.

For CLIs without proper session listing (codex), we'll document the limitation.
For Claude, we can parse the project directory for session IDs.

## Task Breakdown

1. ~~Create `scripts/cli_adapter.sh` with all adapter functions for all 5 CLIs~~ DONE (a031d4d)
2. Update session listing scripts (`get_sessions.sh`, `prompt_new_session.sh`)
3. Update session opening scripts (`new_session.sh`, `switch_session.sh`, `switch_session_exec.sh`)
4. Update dashboard scripts (`dashboard.sh`, `dashboard_refresh.sh`)
5. Update UI scripts (`attach_session.sh`, `tmux-agents.tmux`)
6. Update README.md with CLI Support section

## Iteration 1 Notes

- All 4 CLIs are installed on this machine: claude, opencode, codex, gemini
- Claude sessions stored as UUIDs in `~/.claude/projects/<hash>/`, requires `pwd -P` for macOS symlink resolution
- Codex sessions stored as `rollout-*.jsonl` files, UUID extraction via sed
- Gemini has `--list-sessions` and `--resume <index>` built in
- OpenCode has `session list` subcommand and `--session <id>` flag
- zsh users won't hit issues since all scripts use `#!/usr/bin/env bash`

## Iteration 2 Notes

- Updated `get_sessions.sh` to source cli_adapter.sh and use `agents_list_sessions` (4febbd4)
- Updated `prompt_new_session.sh` to use `agents_next_default_name` and `agents_supports_named_sessions`
- For non-named-session CLIs (claude/opencode/codex/gemini), prompt_new_session.sh now launches directly without prompting for a name
- Demo mode (TMUXAGENTS_DEMO_SESSIONS) preserved in get_sessions.sh

## Iteration 3 Notes

- Updated `new_session.sh` to source cli_adapter.sh and use `agents_new_cmd` (9da354d)
- Updated `switch_session.sh` to use `agents_open_cmd` and `agents_cli_display_name` for dynamic messages
- Updated `switch_session_exec.sh` to use `agents_open_cmd` instead of hardcoded openclaw
- All three scripts now have zero hardcoded openclaw references
- 3 tasks remain: dashboard scripts, attach/tmux comments, README

## Iteration 4 Notes

- Updated `dashboard.sh` to source cli_adapter.sh and use `agents_open_cmd` instead of hardcoded `openclaw tui` (6948db5)
- Updated `dashboard_refresh.sh` similarly — both respawn-pane calls now use the configured CLI
- Updated comment from "openclaw" to "the configured CLI"
- 2 tasks remain: attach/tmux comments, README

## Iteration 5 Notes

- Updated `attach_session.sh` to source cli_adapter.sh and use `agents_cli_display_name` for menu title and error messages (0258b2f)
- Updated `dashboard_menu.sh` similarly — both menu titles now use dynamic CLI name
- Updated `tmux-agents.tmux` comments: "OpenClaw session management" → "AI CLI session management", removed "OpenClaw" from keybinding comments
- Verified: `grep -i openclaw` across all .sh files now only returns matches in `cli_adapter.sh` (which is correct)
- 1 task remains: README.md with CLI Support section

## Iteration 6 Notes

- Updated README.md with CLI Support section (72519e4)
- Added feature matrix table covering all 5 CLIs: openclaw, claude, opencode, codex, gemini
- Documented `@tmuxagents-cli` config option in Configuration section
- Updated Requirements to reference CLI Support section instead of hardcoding OpenClaw
- Updated intro paragraph to list all supported CLIs with links
- All 6 tasks now closed. Issue #4 implementation is complete.
