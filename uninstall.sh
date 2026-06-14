#!/usr/bin/env bash
# uninstall.sh — remove the clixr symlink
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/colors.sh"; . "$ROOT/lib/ui.sh"; . "$ROOT/lib/platform.sh"

bindir="$(bin_install_dir)"
ui_warn "Removing clixr symlink from $bindir"
if ui_confirm "Continue?"; then
  rm -f "$bindir/clixr"
  ui_ok "clixr uninstalled. Repo directory left intact (delete it manually if desired)."
else
  ui_info "Cancelled."
fi
