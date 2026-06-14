#!/usr/bin/env bash
# lib/utils.sh — core helpers shared across clixr plugins

# Require a command, error out with install hint if missing
require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    ui_err "Missing dependency: $cmd"
    local hint; hint=$(pkg_install_cmd "$cmd")
    [ -n "$hint" ] && ui_info "Install with: $hint"
    return 1
  fi
  return 0
}

# Config helpers (simple key=value store)
clixr_config_dir() { echo "${CLIXR_CONFIG:-$HOME/.config/clixr}"; }
clixr_config_file() { echo "$(clixr_config_dir)/config"; }

config_get() {
  local key="$1" file; file=$(clixr_config_file)
  [ -f "$file" ] || return 1
  grep -E "^${key}=" "$file" 2>/dev/null | head -1 | cut -d= -f2-
}

config_set() {
  local key="$1" val="$2" file dir
  dir=$(clixr_config_dir); file=$(clixr_config_file)
  mkdir -p "$dir"
  touch "$file"
  if grep -qE "^${key}=" "$file" 2>/dev/null; then
    local tmp; tmp=$(mktemp)
    grep -vE "^${key}=" "$file" > "$tmp"
    mv "$tmp" "$file"
  fi
  printf '%s=%s\n' "$key" "$val" >> "$file"
}

# Human-readable byte sizes
human_bytes() {
  local bytes="$1"
  if [ "$bytes" -ge 1073741824 ]; then
    printf '%d.%01d GB' $(( bytes / 1073741824 )) $(( (bytes % 1073741824) * 10 / 1073741824 ))
  elif [ "$bytes" -ge 1048576 ]; then
    printf '%d.%01d MB' $(( bytes / 1048576 )) $(( (bytes % 1048576) * 10 / 1048576 ))
  elif [ "$bytes" -ge 1024 ]; then
    printf '%d.%01d KB' $(( bytes / 1024 )) $(( (bytes % 1024) * 10 / 1024 ))
  else
    printf '%d B' "$bytes"
  fi
}

# Die with message
die() { ui_err "$*"; exit 1; }
