#!/usr/bin/env bash
# install.sh — cinematic, platform-aware installer for clixr
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for _l in colors ui platform utils; do . "$ROOT/lib/$_l.sh"; done

FULL=0; UNINSTALL=0; NOWIZARD=0; QUIET_ANIM=0
for arg in "$@"; do case "$arg" in
  --full) FULL=1 ;; --uninstall) UNINSTALL=1 ;;
  --no-wizard) NOWIZARD=1 ;; --fast) QUIET_ANIM=1 ;;
esac; done

CATS=(net sec sys dev web rice fun)
declare -A CAT_LABEL=(
  [net]="networking & recon" [sec]="security & crypto" [sys]="system management"
  [dev]="developer tools" [web]="web & downloads" [rice]="customization" [fun]="easter eggs")
declare -A CAT_ICON=([net]="🌐" [sec]="🔐" [sys]="🖥" [dev]="🛠" [web]="🕸" [rice]="🎨" [fun]="🎉")

LOGO=(
'   ██████╗██╗     ██╗██╗  ██╗██████╗ '
'  ██╔════╝██║     ██║╚██╗██╔╝██╔══██╗'
'  ██║     ██║     ██║ ╚███╔╝ ██████╔╝'
'  ██║     ██║     ██║ ██╔██╗ ██╔══██╗'
'  ╚██████╗███████╗██║██╔╝ ██╗██║  ██║'
'   ╚═════╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝')

anim() { [ "$QUIET_ANIM" -eq 0 ] && [ -t 1 ]; }
pause() { anim && sleep "${1:-0.04}"; }

cat_count() { ls "$ROOT/plugins/$1" 2>/dev/null | grep -c . ; }
tool_total() { find "$ROOT/plugins" -type f | wc -l | xargs; }

# ── Cinematic intro ──
intro() {
  clear 2>/dev/null || true
  printf '\n'
  if anim; then
    local l; for l in "${LOGO[@]}"; do printf '%s%s%s\n' "$BCYAN" "$l" "$RESET"; sleep 0.05; done
  else
    local l; for l in "${LOGO[@]}"; do printf '%s%s%s\n' "$BCYAN" "$l" "$RESET"; done
  fi
  printf '\n'
  mgradient "        ⚡  the ultimate CLI toolkit  ⚡" 51 45 39 99 201
  printf '   %s%s tools%s · %s7 categories%s · %szero bloat%s\n' \
    "$BGREEN" "$(tool_total)" "$RESET" "$BCYAN" "$RESET" "$DIM" "$RESET"
  printf '\n'
  ui_grule
}

# ── Phase banner ──
phase() {
  printf '\n %s%s%s %s%s%s\n' "$(bg256 51)$(fg256 0)$BOLD" " $1 " "$RESET" "$BOLD" "$2" "$RESET"
}

# ── Uninstall path ──
do_uninstall() {
  intro
  local bindir; bindir="$(bin_install_dir)"
  printf '\n'
  ui_warn "This removes the clixr symlink from ${BWHITE}$bindir${RESET}"
  if ui_confirm "Continue?"; then
    rm -f "$bindir/clixr"; ui_ok "clixr uninstalled (repo left intact)."
  else ui_info "Cancelled."; fi
}
[ "$UNINSTALL" -eq 1 ] && { do_uninstall; exit 0; }

START_TS=$(date +%s)
intro

# ── Phase 1: system scan ──
phase "1/4" "scanning your system"
pause 0.2
ui_kv "platform" "${BWHITE}$(detect_os)${RESET} ${DIM}($(detect_arch))${RESET}"
ui_kv "shell"    "${BWHITE}$(detect_shell)${RESET}"
ui_kv "terminal" "${BWHITE}$(detect_term)${RESET}"
ui_kv "target"   "${BWHITE}$(bin_install_dir)${RESET}"

# ── Phase 2: dependencies ──
phase "2/4" "checking dependencies"
pause 0.2
missing=()
req=(bash awk sed grep); opt=(curl nc openssl dig jq qrencode)
for d in "${req[@]}"; do
  if has_cmd "$d"; then ui_ok "$d ${DIM}required${RESET}"
  else ui_err "$d ${DIM}required — missing${RESET}"; missing+=("$d"); fi
  pause 0.03
done
for d in "${opt[@]}"; do
  if has_cmd "$d"; then ui_ok "$d ${DIM}optional${RESET}"
  else ui_dot "$d ${DIM}optional — enables more tools${RESET}"; fi
  pause 0.03
done
if [ ${#missing[@]} -gt 0 ]; then
  printf '\n'; ui_err "Missing required: ${BWHITE}${missing[*]}${RESET}"
  hint="$(pkg_install_cmd "${missing[0]}")"; [ -n "$hint" ] && ui_info "try: ${GRAY}$hint${RESET}"
  exit 1
fi

# ── Phase 3: install ──
phase "3/4" "installing tools"
pause 0.2
chmod +x "$ROOT/bin/clixr" 2>/dev/null || true
find "$ROOT/plugins" -type f -exec chmod +x {} \; 2>/dev/null || true

for c in "${CATS[@]}"; do
  n=$(cat_count "$c")
  if anim; then
    ui_spin_start "${CAT_ICON[$c]} installing ${BOLD}$c${RESET} ${DIM}(${CAT_LABEL[$c]})${RESET}"
    sleep 0.28; ui_spin_stop
  fi
  printf '   %s✓%s %s %-5s %s%-22s%s %s%2d tools%s\n' \
    "$BGREEN" "$RESET" "${CAT_ICON[$c]}" "$c" "$DIM" "${CAT_LABEL[$c]}" "$RESET" "$BCYAN" "$n" "$RESET"
done

bindir="$(bin_install_dir)"; mkdir -p "$bindir"
ln -sf "$ROOT/bin/clixr" "$bindir/clixr"
printf '\n'; ui_ok "linked ${BCYAN}clixr${RESET} → $bindir/clixr"
case ":$PATH:" in *":$bindir:"*) ;; *)
  ui_warn "add to PATH:  ${GRAY}export PATH=\"$bindir:\$PATH\"${RESET}" ;;
esac

# ── Phase 4: personalize ──
if [ "$FULL" -eq 0 ] && [ "$NOWIZARD" -eq 0 ] && [ -t 0 ]; then
  phase "4/4" "personalize"
  if ui_confirm "Pick a terminal theme now?"; then
    themes=(dracula cyberpunk nord gruvbox matrix tokyonight catppuccin synthwave)
    idx=$(ui_menu "choose a theme:" "${themes[@]}")
    config_set theme "${themes[$idx]}"
    ui_ok "theme set to ${BCYAN}${themes[$idx]}${RESET}"
  fi
  if ui_confirm "Enable aliases + tab-completion in your shell?"; then
    rc="$HOME/.bashrc"; [ "$(detect_shell)" = "zsh" ] && rc="$HOME/.zshrc"
    line="source \"$ROOT/clixr.sh\"  # clixr init"
    grep -qF "$line" "$rc" 2>/dev/null || echo "$line" >> "$rc"
    ui_ok "added to ${BWHITE}$rc${RESET} ${DIM}(restart shell)${RESET}"
  fi
else
  phase "4/4" "personalize ${DIM}(skipped)${RESET}"
fi

# ── Summary ──
ELAPSED=$(( $(date +%s) - START_TS )); [ "$ELAPSED" -lt 1 ] && ELAPSED=1
printf '\n'; ui_grule; printf '\n'
ui_box "✨  clixr is ready" \
  "" \
  "$(tool_total) tools installed in ${ELAPSED}s across 7 categories" \
  "" \
  "${BGREEN}clixr list${RESET}        ${DIM}browse every tool${RESET}" \
  "${BGREEN}clixr sysinfo${RESET}     ${DIM}system report${RESET}" \
  "${BGREEN}clixr curl${RESET} <url>  ${DIM}fancy http client${RESET}" \
  "${BGREEN}clixr matrix${RESET}      ${DIM}🟢 wake up, neo…${RESET}" \
  "${BGREEN}clixr help${RESET}        ${DIM}full help${RESET}" \
  ""
printf '\n'
mgradient "   built for terminal addicts — star it if it sparks joy ⭐" 201 165 99 45 51
printf '\n'
