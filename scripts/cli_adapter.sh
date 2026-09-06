#!/usr/bin/env bash
#
# cli_adapter.sh — CLI abstraction layer for tmux-agents
# Provides functions to list/open/create sessions across multiple AI CLIs.
# Source this file from other scripts: source "$SCRIPTS_DIR/cli_adapter.sh"
#
# Supported CLIs: claude (default), openclaw, opencode, codex, gemini
#
# Session list format (agents_list_sessions): one line per session,
#   <id> <TAB> <label> [<TAB> extra columns...]
# Column 1 is what scripts act on; columns 2+ are what the picker shows.
# Use $AGENTS_FZF_OPTS with fzf to display only the label columns.

ADAPTER_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AGENTS_FZF_OPTS="--delimiter='\\t' --with-nth=2.. --tabstop=4 --no-hscroll"

# ── Resolve configured CLI ──────────────────────────────────────────────────────
agents_cli_name() {
  local cli
  cli=$(tmux show-option -gqv "@tmuxagents-cli" 2>/dev/null)
  echo "${cli:-claude}"
}

# ── List sessions (one per line) ────────────────────────────────────────────────
# Output: session identifiers, one per line. Format varies by CLI.
agents_list_sessions() {
  local cli
  cli=$(agents_cli_name)

  if [ "$cli" = "claude" ]; then
    bash "$ADAPTER_DIR/claude_sessions.sh"
    return
  fi

  # Other CLIs: plain identifiers → label is the identifier itself
  agents_list_raw_ids | awk -F'\t' 'NF { print $1 "\t" $1 }'
}

agents_list_raw_ids() {
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw)
      openclaw sessions --json 2>/dev/null \
        | jq -r '.sessions[] | .key | sub("agent:main:"; "") | select(test(":") | not)'
      ;;

    claude)
      # id, title, relative time, project — scanned from transcripts, cached by mtime
      bash "$ADAPTER_DIR/claude_sessions.sh"
      ;;

    opencode)
      opencode session list 2>/dev/null \
        | tail -n +2 \
        | awk '{print $1}' \
        | grep -v '^$'
      ;;

    codex)
      # Codex stores sessions in ~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl
      # Extract the UUID portion for resume.
      local sessions_dir="$HOME/.codex/sessions"
      if [ -d "$sessions_dir" ]; then
        find "$sessions_dir" -name 'rollout-*.jsonl' 2>/dev/null \
          | sort -r \
          | head -20 \
          | while IFS= read -r f; do
              basename "$f" .jsonl | sed 's/^rollout-[0-9T-]*//' | sed 's/^-//'
            done
      fi
      ;;

    gemini)
      # gemini --list-sessions outputs session info to stderr/stdout.
      # Parse session indices (1-based) for use with --resume <index>.
      gemini --list-sessions 2>&1 \
        | grep -E '^\s*[0-9]+\.' \
        | sed 's/^[[:space:]]*//' \
        | head -20
      ;;

    *)
      echo "tmux-agents: unknown CLI '$cli'" >&2
      return 1
      ;;
  esac
}

# ── Command to open/resume a session ────────────────────────────────────────────
# Usage: agents_open_cmd <session-identifier>
# Returns: the shell command string to run in a pane.
agents_open_cmd() {
  local session="$1"
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw)
      echo "openclaw tui --session '$session'"
      ;;
    claude)
      # Resume from the session's own project directory so Claude finds it
      # and relative paths in the conversation still make sense.
      local cwd
      cwd=$(bash "$ADAPTER_DIR/claude_sessions.sh" cwd "$session")
      if [ -n "$cwd" ] && [ -d "$cwd" ]; then
        echo "cd '$cwd' && claude --resume '$session'"
      else
        echo "claude --resume '$session'"
      fi
      ;;
    opencode)
      echo "opencode --session '$session'"
      ;;
    codex)
      echo "codex resume '$session'"
      ;;
    gemini)
      # Gemini sessions are referenced by index from --list-sessions output.
      # If the identifier looks like "N. ..." extract just the number.
      local idx
      idx=$(echo "$session" | grep -oE '^[0-9]+')
      if [ -n "$idx" ]; then
        echo "gemini --resume '$idx'"
      else
        echo "gemini --resume '$session'"
      fi
      ;;
    *)
      echo "echo 'tmux-agents: unknown CLI'"
      ;;
  esac
}

# ── Command to start a new session ──────────────────────────────────────────────
# Usage: agents_new_cmd [session-name]
# Returns: the shell command string to run in a pane.
agents_new_cmd() {
  local session="$1"
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw)
      echo "openclaw tui --session '$session'"
      ;;
    claude)
      # Claude doesn't support naming sessions; just start a new one.
      echo "claude"
      ;;
    opencode)
      # OpenCode doesn't take a session name for new sessions.
      echo "opencode"
      ;;
    codex)
      echo "codex"
      ;;
    gemini)
      echo "gemini"
      ;;
    *)
      echo "echo 'tmux-agents: unknown CLI'"
      ;;
  esac
}

# ── Next default session name ───────────────────────────────────────────────────
# Returns a default name for the next new session (used by prompt_new_session.sh).
agents_next_default_name() {
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw)
      local next
      next=$(openclaw sessions --json 2>/dev/null \
        | jq '[.sessions[].key | sub("agent:main:"; "") | select(test(":") | not) | select(test("^agent-[0-9]+$"))] | length + 1' \
        2>/dev/null)
      [ -z "$next" ] && next=1
      echo "agent-$next"
      ;;
    claude|opencode|codex|gemini)
      # These CLIs manage session IDs internally; just use a simple counter.
      echo "session-$(date +%s | tail -c 5)"
      ;;
    *)
      echo "session-1"
      ;;
  esac
}

# ── Display name for the CLI (used in UI messages) ──────────────────────────────
agents_cli_display_name() {
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw) echo "OpenClaw" ;;
    claude)   echo "Claude Code" ;;
    opencode) echo "OpenCode" ;;
    codex)    echo "Codex" ;;
    gemini)   echo "Gemini" ;;
    *)        echo "$cli" ;;
  esac
}

# ── Check if the CLI supports session listing ───────────────────────────────────
agents_supports_session_list() {
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw|claude|opencode|gemini) return 0 ;;
    codex) return 0 ;;  # Limited — file-based listing
    *) return 1 ;;
  esac
}

# ── Check if the CLI supports named sessions ────────────────────────────────────
agents_supports_named_sessions() {
  local cli
  cli=$(agents_cli_name)

  case "$cli" in
    openclaw) return 0 ;;
    *) return 1 ;;
  esac
}

# ── Label for a session id (for pane titles / messages) ─────────────────────────
# Usage: agents_session_label <id>
agents_session_label() {
  local id="$1" label
  label=$(agents_list_sessions | awk -F'\t' -v id="$id" '$1 == id { print $2; exit }')
  echo "${label:-$id}"
}
