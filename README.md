# tmux-agents

A [TPM](https://github.com/tmux-plugins/tpm) plugin for managing [OpenClaw](https://openclaw.ai) sessions directly from tmux.

Open new panes or windows pre-loaded with an OpenClaw session. Attach to existing sessions with a fuzzy picker. One persistent dashboard that shows all your sessions at once.

## Keybindings

`prefix + g` enters the **[claw]** key table:

| Key | Action |
|-----|--------|
| `g` | Switch **current pane** to existing session (fzf picker, respawn in-place) |
| `n` | New session → prompt for name → open in **pane** (split) |
| `N` | New session → prompt for name → open in **window** |
| `a` | Attach existing session → fzf picker → open in **pane** |
| `A` | Attach existing session → fzf picker → open in **window** |
| `d` | **Dashboard** — switch to it (create if not exists) |
| `D` | **Dashboard menu** — hide/show/refresh/relayout/kill |
| `Esc` | Cancel |

> **Tip:** While in the dashboard window, press `prefix + Space` to cycle through tmux's built-in layouts.

## Dashboard

`prefix g d` opens a persistent window (`claw:dash`) showing all your OpenClaw sessions in a tiled grid. Each pane runs a live `openclaw tui` session.

The dashboard is **created once and reused** — pressing `prefix g d` again just switches to it.

### Dashboard Menu (`prefix g D`)

| Option | Key | Action |
|--------|-----|--------|
| Hide session | `h` | fzf pick a visible session → remove from dashboard |
| Show hidden | `u` | fzf pick a hidden session → restore to dashboard |
| Refresh | `r` | Sync panes: add new sessions, remove hidden/dead ones |
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

- [OpenClaw](https://openclaw.ai) CLI (`openclaw`)
- [`jq`](https://stedolan.github.io/jq/)
- [`fzf`](https://github.com/junegunn/fzf) _(optional — falls back to `display-menu`)_

## Configuration

```tmux
# Change trigger key (default: g)
set -g @openclaw-trigger-key "g"

# Pane split direction: h (horizontal, default) or v (vertical)
set -g @openclaw-split-direction "h"

# Dashboard default layout: tiled | even-vertical | even-horizontal
set -g @openclaw-dashboard-layout "tiled"

# Max panes in dashboard (0 = no limit)
set -g @openclaw-dashboard-max "0"
```

## License

MIT
