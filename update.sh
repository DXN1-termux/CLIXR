#!/usr/bin/env bash
# update.sh — self-update clixr from its git remote
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$ROOT/lib/colors.sh"; . "$ROOT/lib/ui.sh"

if [ ! -d "$ROOT/.git" ]; then
  ui_err "Not a git checkout — clone clixr with git to enable updates."
  exit 1
fi

ui_info "Checking for updates..."
before=$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null)
if git -C "$ROOT" pull --ff-only 2>/dev/null; then
  after=$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null)
  if [ "$before" = "$after" ]; then
    ui_ok "Already up to date ($after)."
  else
    ui_ok "Updated $before → $after"
    ui_info "Changelog:"
    git -C "$ROOT" log --oneline "$before..$after" | sed 's/^/  /'
    find "$ROOT/plugins" -type f -exec chmod +x {} \; 2>/dev/null || true
  fi
else
  ui_err "Update failed. Resolve local changes and retry."
  exit 1
fi
