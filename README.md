# tmux-openclaw

A [TPM](https://github.com/tmux-plugins/tpm) plugin for managing [OpenClaw](https://openclaw.ai) sessions directly from tmux.

Open new panes or windows pre-loaded with an OpenClaw session. Attach to existing sessions with a fuzzy picker. All without leaving tmux.

## Keybindings

`prefix + g` enters the **[claw]** key table:

| Key | Action |
|-----|--------|
| `g` | Switch **current pane** to existing session (fzf picker) |
| `n` | New OpenClaw session → open in **pane** (split) |
| `N` | New OpenClaw session → open in **window** |
| `a` | Attach existing session → open in **pane** |
| `A` | Attach existing session → open in **window** |
| `d` | **Dashboard** — all sessions in a **grid** layout (new window) |
| `v` | **Dashboard** — all sessions **vertical** layout (new window) |
| `h` | **Dashboard** — all sessions **horizontal** layout (new window) |
| `Esc` | Cancel |

## Install

### Via TPM (recommended)

Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'sergiopx/tmux-openclaw'
```

Then press `prefix + I` to install.

### Manual

```bash
git clone https://github.com/sergiopx/tmux-openclaw ~/.tmux/plugins/tmux-openclaw
~/.tmux/plugins/tmux-openclaw/tmux-openclaw.tmux
```

## Requirements

- [OpenClaw](https://openclaw.ai) CLI (`openclaw`)
- [`jq`](https://stedolan.github.io/jq/)
- [`fzf`](https://github.com/junegunn/fzf) _(optional — falls back to `display-menu`)_

## Configuration

All options go in `~/.tmux.conf`:

```tmux
# Change trigger key from g to something else
set -g @openclaw-trigger-key "g"

# Pane split direction: h (horizontal, default) or v (vertical)
set -g @openclaw-split-direction "h"
```

## How It Works

- `n` / `N` — prompts for a session name (default: `claw-1`, `claw-2`, …), then opens `openclaw tui --session <name>` in a new pane or window. The pane title is set to match the session name.
- `g` — fzf picker → **respawns the current pane** with the selected session (replaces whatever was running in-place).
- `a` / `A` — fetches your OpenClaw sessions, presents them in an fzf popup (or `display-menu` fallback), and opens the selected session in a new pane or window.
- `d` / `v` / `h` — opens **all user sessions** in a new window. Pane skeleton is created instantly, then all sessions load in parallel:
  - `d` → `tiled` grid
  - `v` → `even-vertical` (stacked top/bottom)
  - `h` → `even-horizontal` (side by side)
## License

MIT
