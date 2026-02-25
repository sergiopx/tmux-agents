# tmux-agents

Manage your AI agent sessions in tmux — open, attach, switch, and dashboard.

A [TPM](https://github.com/tmux-plugins/tpm) plugin for managing AI agent CLI sessions directly from tmux. Supports [OpenClaw](https://openclaw.ai), [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [OpenCode](https://opencode.ai), [Codex](https://github.com/openai/codex), and [Gemini CLI](https://github.com/google-gemini/gemini-cli). Open new panes or windows pre-loaded with a session, attach to existing ones with a fuzzy picker, and keep a persistent dashboard showing all your agents at once.

<!-- GIF: dashboard -->

## Keybindings

`prefix + g` enters the **[agents]** key table:

| Key | Action |
|-----|--------|
| `g` | Switch **current pane** to existing session (fzf, respawn in-place) |
| `n` | New session → prompt for name → open in **pane** (split) |
| `N` | New session → prompt for name → open in **window** |
| `a` | Attach existing session → fzf picker → open in **pane** |
| `A` | Attach existing session → fzf picker → open in **window** |
| `d` | **Dashboard** — switch to it (create if not exists) |
| `D` | **Dashboard menu** — hide/show/refresh/relayout/kill |
| `Esc` | Cancel |

> **Tip:** While in the dashboard window, press `prefix + Space` to cycle tmux's built-in layouts.

## Dashboard

`prefix g d` opens a persistent window (`agents:dash`) showing all your sessions in a tiled grid. Each pane runs a live agent session. Created once, reused forever — pressing `prefix g d` again just switches to it.

<!-- GIF: menu -->

### Dashboard Menu (`prefix g D`)

| Option | Key | Action |
|--------|-----|--------|
| Hide session | `h` | Remove a session from the dashboard |
| Show hidden | `u` | Restore a hidden session |
| Refresh | `r` | Sync panes — adds new sessions, removes hidden/dead ones |
| Layout: Grid | `1` | `tiled` layout |
| Layout: Vertical | `2` | `even-vertical` layout |
| Layout: Horizontal | `3` | `even-horizontal` layout |
| Kill dashboard | `x` | Close the dashboard window |

Hidden sessions are saved to `~/.config/tmux-agents/hidden` and persist across restarts.

## Install

### Via TPM (recommended)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'sergiopx/tmux-agents'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/sergiopx/tmux-agents ~/.tmux/plugins/tmux-agents
~/.tmux/plugins/tmux-agents/tmux-agents.tmux
```

## Requirements

- At least one supported AI CLI (see [CLI Support](#cli-support) below)
- [`jq`](https://stedolan.github.io/jq/) *(required for OpenClaw session listing)*
- [`fzf`](https://github.com/junegunn/fzf) *(optional — falls back to `display-menu`)*

## Configuration

```tmux
set -g @tmuxagents-cli               "openclaw"  # AI CLI to use (see CLI Support below)
set -g @tmuxagents-trigger-key       "g"         # trigger key after prefix (default: g)
set -g @tmuxagents-split-direction   "h"         # pane split direction: h or v
set -g @tmuxagents-dashboard-layout  "tiled"     # tiled | even-vertical | even-horizontal
set -g @tmuxagents-dashboard-max     "0"         # max panes in dashboard (0 = no limit)
```

## CLI Support

Set `@tmuxagents-cli` to one of the supported values below:

| CLI | Value | List sessions | Resume session | Named sessions | New session |
|-----|-------|:---:|:---:|:---:|:---:|
| [OpenClaw](https://openclaw.ai) | `openclaw` (default) | Yes | Yes | Yes | Yes |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `claude` | Yes* | Yes | No | Yes |
| [OpenCode](https://opencode.ai) | `opencode` | Yes | Yes | No | Yes |
| [Codex](https://github.com/openai/codex) | `codex` | Yes* | Yes | No | Yes |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `gemini` | Yes | Yes | No | Yes |

**Feature notes:**

- **List sessions** — Populates the fzf picker for attach/switch. CLIs marked with `*` use file-based session discovery instead of a built-in list command.
- **Resume session** — Open an existing session in a pane or window.
- **Named sessions** — Only OpenClaw supports human-friendly session names (e.g., `agent-1`). Other CLIs use internal IDs (UUIDs or indices).
- **New session** — Launch a fresh CLI instance. For CLIs without named sessions, the name prompt is skipped and the CLI launches directly.

### CLI-specific details

- **OpenClaw** — Sessions listed via `openclaw sessions --json`. Requires `jq`.
- **Claude Code** — Sessions discovered from `~/.claude/projects/` by scanning `.jsonl` files. Session IDs are UUIDs.
- **OpenCode** — Sessions listed via `opencode session list`. Resumed with `--session <id>`.
- **Codex** — Sessions discovered from `~/.codex/sessions/` by scanning `rollout-*.jsonl` files. Shows the 20 most recent.
- **Gemini** — Sessions listed via `gemini --list-sessions`. Resumed by index with `--resume <index>`.

## License

MIT
