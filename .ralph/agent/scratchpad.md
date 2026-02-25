# Issue #2: Keybinding Rework

## Understanding

Current bindings (prefix+g enters [agents] table):
- g → switch_session.sh (fzf, respawn current pane)
- n → prompt_new_session.sh pane (prompt name, split new pane)
- N → prompt_new_session.sh window (prompt name, new window)
- a → attach_session.sh pane (fzf pick existing, split new pane)
- A → attach_session.sh window (fzf pick existing, new window)
- d/D → dashboard / dashboard menu
- Esc → cancel

New bindings (prefix+a enters [agents] table, default trigger: g→a):
- p → attach_session.sh pane (was `a` — fzf pick existing, open in new pane)
- P → prompt_new_session.sh pane (was `n` — prompt name, open in new pane)
- w → attach_session.sh window (was `A` — fzf pick existing, open in new window)
- W → prompt_new_session.sh window (was `N` — prompt name, open in new window)
- a → switch_session.sh (was `g` — fzf, respawn current pane in-place)
- A → prompt_new_session.sh current (NEW — prompt name, respawn current pane)
- d/D → dashboard (unchanged)
- Esc → cancel (unchanged)

## Plan

Three tasks:
1. Add "current" mode to new_session.sh (for the new `A` binding — respawn-pane instead of split/window)
2. Update tmux-agents.tmux: change default trigger g→a, remap all bindings, update comments
3. Update README.md: keybindings table, all prefix+g references, config default

## Iteration 1 — DONE
Task 1 complete: Added "current" mode to new_session.sh and prompt_new_session.sh.
- new_session.sh: added `elif [ "$MODE" = "current" ]` branch using `tmux respawn-pane -k`
- prompt_new_session.sh: updated comment to document mode: pane | window | current
- Committed as 1307202

Next: Task 2 — Update tmux-agents.tmux (now unblocked)

## Iteration 2 — DONE
Task 2 complete: Updated tmux-agents.tmux with new keybinding layout.
- Default trigger changed from `g` to `a`
- Remapped all [agents] key table bindings: p/P (pane), w/W (window), a/A (current)
- Added new `A` binding using `prompt_new_session.sh current` (from iteration 1)
- Comments updated to reflect new layout
- Committed as cb9089b

Next: Task 3 — Update README.md (now unblocked)

## Iteration 3 — DONE
Task 3 complete: Updated README.md with new keybinding layout.
- Keybindings table: replaced old g/n/N/a/A with new p/P/w/W/a/A layout
- Added new `A` row: "New session → prompt for name → respawn current pane in-place"
- All `prefix+g` / `prefix g` references → `prefix+a` / `prefix a`
- Config default: `"g"` → `"a"` with updated comment
- Committed as b5cba0f

All 3 tasks complete. Issue #2 fully resolved.
