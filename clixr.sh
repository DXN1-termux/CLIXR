#!/usr/bin/env bash
# clixr.sh — shell init: aliases, completions, and optional theme.
# Add to your ~/.bashrc or ~/.zshrc:   source /path/to/clixr/clixr.sh

_CLIXR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Ensure clixr is on PATH
case ":$PATH:" in *":$_CLIXR_DIR/bin:"*) ;; *) export PATH="$_CLIXR_DIR/bin:$PATH" ;; esac

# Handy aliases
alias cx='clixr'
alias cxl='clixr list'
alias cxf='clixr fetch'

# Apply saved theme, if any
_clixr_theme="$(clixr config get theme 2>/dev/null)"
if [ -n "$_clixr_theme" ] && [ -f "$_CLIXR_DIR/themes/$_clixr_theme.theme" ]; then
  # shellcheck source=/dev/null
  . "$_CLIXR_DIR/themes/$_clixr_theme.theme"
fi
unset _clixr_theme

# Build the list of completable commands (tools + core verbs + categories)
_clixr_commands() {
  local core="list help version doctor update config logo net sec sys dev web rice fun"
  local tools; tools="$(find "$_CLIXR_DIR/plugins" -type f -exec basename {} \; 2>/dev/null | tr '\n' ' ')"
  printf '%s %s' "$core" "$tools"
}

# ── bash completion ──
if [ -n "${BASH_VERSION:-}" ]; then
  _clixr_complete_bash() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    if [ "$COMP_CWORD" -eq 1 ]; then
      # shellcheck disable=SC2207
      COMPREPLY=( $(compgen -W "$(_clixr_commands)" -- "$cur") )
    fi
  }
  complete -F _clixr_complete_bash clixr cx 2>/dev/null
fi

# ── zsh completion ──
if [ -n "${ZSH_VERSION:-}" ]; then
  _clixr_complete_zsh() {
    local -a cmds
    # shellcheck disable=SC2206,SC2296
    cmds=(${(s: :)$(_clixr_commands)})
    compadd -- $cmds
  }
  compdef _clixr_complete_zsh clixr cx 2>/dev/null
fi
