#!/usr/bin/env bash
# lib/ui.sh — the aesthetic engine for clixr
# Components: badges, boxes/panels, rules, tables, key/value, progress,
# spinners (multi-style), typewriter, prompts, menus, headers, reveal.

# shellcheck source=/dev/null
[ -n "${CLIXR_LIB:-}" ] && . "${CLIXR_LIB}/colors.sh"

# Box-drawing glyphs (rounded by default)
: "${UI_TL:=╭}" "${UI_TR:=╮}" "${UI_BL:=╰}" "${UI_BR:=╯}"
: "${UI_H:=─}" "${UI_V:=│}" "${UI_ML:=├}" "${UI_MR:=┤}"

# Strip ANSI for width calculations (uses a literal ESC byte for portability)
ui_strip() { printf '%s' "$1" | sed "s/$(printf '\033')\[[0-9;]*m//g"; }
ui_width() { local s; s="$(ui_strip "$1")"; printf '%s' "${#s}"; }
ui_cols()  { tput cols 2>/dev/null || echo 72; }

# ── Badges ────────────────────────────────────────────────────────────────────
ui_ok()   { printf ' %s✓%s %s\n' "$BGREEN"   "$RESET" "$*"; }
ui_err()  { printf ' %s✗%s %s\n' "$BRED"     "$RESET" "$*" >&2; }
ui_warn() { printf ' %s▲%s %s\n' "$BYELLOW"  "$RESET" "$*"; }
ui_info() { printf ' %s•%s %s\n' "$BCYAN"    "$RESET" "$*"; }
ui_step() { printf ' %s❯%s %s\n' "$BMAGENTA" "$RESET" "$*"; }
ui_dot()  { printf ' %s◦%s %s\n' "$GRAY"     "$RESET" "$*"; }

# Pill-style label badge: ui_badge <256color> "TEXT"
ui_badge() { printf '%s %s %s' "$(bg256 "$1")$(fg256 0)$BOLD" "$2" "$RESET"; }

# ── Key / value rows ────────────────────────────────────────────────────────────
# ui_kv "key" "value" [keywidth]
ui_kv() {
  local k="$1" v="$2" w="${3:-14}"
  printf '   %s%-*s%s %s%s%s %s\n' "$GRAY" "$w" "$k" "$RESET" "$DIM" "$UI_V" "$RESET" "$v"
}

# ── Rules / dividers ─────────────────────────────────────────────────────────────
ui_rule() {
  local label="${1:-}" cols i
  cols=$(ui_cols)
  printf '%s' "$GRAY"
  if [ -n "$label" ]; then
    printf '%s─ %s%s%s %s' "$UI_H" "$BOLD$BCYAN" "$label" "$RESET$GRAY" ""
    local n=$(( cols - $(ui_width "$label") - 5 ))
    for (( i=0; i<n; i++ )); do printf '%s' "$UI_H"; done
  else
    for (( i=0; i<cols; i++ )); do printf '%s' "$UI_H"; done
  fi
  printf '%s\n' "$RESET"
}

# Gradient horizontal rule
ui_grule() {
  local cols i s=51 e=201; cols=$(ui_cols); [ "$cols" -gt 80 ] && cols=80
  for (( i=0; i<cols; i++ )); do
    local c=$(( s + (e - s) * i / (cols - 1) ))
    printf '%s━' "$(fg256 "$c")"
  done
  printf '%s\n' "$RESET"
}

# ── Box / panel ──────────────────────────────────────────────────────────────────
# ui_box "title" "line" ...   (rounded cyan border)
ui_box() {
  local title="$1"; shift
  local lines=("$@") l maxw
  maxw=$(ui_width "$title")
  for l in ${lines[@]+"${lines[@]}"}; do local w; w=$(ui_width "$l"); [ "$w" -gt "$maxw" ] && maxw=$w; done
  local width=$(( maxw + 4 )) i top bot
  top="$UI_TL"; bot="$UI_BL"
  for (( i=0; i<width-2; i++ )); do top+="$UI_H"; bot+="$UI_H"; done
  top+="$UI_TR"; bot+="$UI_BR"
  printf '%s%s%s\n' "$BCYAN" "$top" "$RESET"
  if [ -n "$title" ]; then
    local pad=$(( width - 3 - $(ui_width "$title") ))
    printf '%s%s%s %s%s%s%*s%s%s%s\n' "$BCYAN" "$UI_V" "$RESET" "$BOLD$BWHITE" "$title" "$RESET" "$pad" "" "$BCYAN" "$UI_V" "$RESET"
    local sep="$UI_ML"; for (( i=0; i<width-2; i++ )); do sep+="$UI_H"; done; sep+="$UI_MR"
    printf '%s%s%s\n' "$BCYAN" "$sep" "$RESET"
  fi
  for l in ${lines[@]+"${lines[@]}"}; do
    local pad=$(( width - 3 - $(ui_width "$l") ))
    printf '%s%s%s %b%*s%s%s%s\n' "$BCYAN" "$UI_V" "$RESET" "$l" "$pad" "" "$BCYAN" "$UI_V" "$RESET"
  done
  printf '%s%s%s\n' "$BCYAN" "$bot" "$RESET"
}

# Panel with a colored left bar: ui_panel <256color> "title" "line" ...
ui_panel() {
  local color="$1" title="$2"; shift 2
  printf '%s▌%s %s%s%s\n' "$(fg256 "$color")" "$RESET" "$BOLD" "$title" "$RESET"
  local l
  for l in "$@"; do printf '%s▌%s %b\n' "$(fg256 "$color")" "$RESET" "$l"; done
}

# ── Tables ────────────────────────────────────────────────────────────────────
# ui_table "Col1|Col2|Col3" "a|b|c" "d|e|f" ...
ui_table() {
  local header="$1"; shift
  local rows=("$@") IFS='|'
  read -ra cols <<< "$header"
  local n=${#cols[@]} i
  declare -a widths
  for (( i=0; i<n; i++ )); do widths[$i]=${#cols[$i]}; done
  local r
  for r in ${rows[@]+"${rows[@]}"}; do
    read -ra cells <<< "$r"
    for (( i=0; i<n; i++ )); do
      local w; w=$(ui_width "${cells[$i]:-}"); [ "$w" -gt "${widths[$i]}" ] && widths[$i]=$w
    done
  done
  printf '  '
  for (( i=0; i<n; i++ )); do printf '%s%-*s%s  ' "$BOLD$BCYAN" "${widths[$i]}" "${cols[$i]}" "$RESET"; done
  printf '\n  '
  for (( i=0; i<n; i++ )); do local j; printf '%s' "$GRAY"; for (( j=0; j<${widths[$i]}; j++ )); do printf '─'; done; printf '%s  ' "$RESET"; done
  printf '\n'
  for r in ${rows[@]+"${rows[@]}"}; do
    read -ra cells <<< "$r"
    printf '  '
    for (( i=0; i<n; i++ )); do printf '%-*s  ' "${widths[$i]}" "${cells[$i]:-}"; done
    printf '\n'
  done
}

# ── Progress bar (gradient fill) ─────────────────────────────────────────────────
ui_progress() {
  local cur="$1" total="$2" label="${3:-}" width=28
  local filled=$(( cur * width / total )) i bar=""
  for (( i=0; i<width; i++ )); do
    if [ "$i" -lt "$filled" ]; then
      local c=$(( 46 + (i * 5 / width) )); bar+="$(fg256 "$c")█"
    else bar+="$(fg256 236)░"; fi
  done
  local pct=$(( cur * 100 / total ))
  printf '\r   %-20s %s%s %3d%%' "$label" "$bar" "$RESET" "$pct"
  [ "$cur" -ge "$total" ] && printf '\n'
}

# ── Spinners (style via UI_SPINNER: braille|dots|line|moon|bounce) ────────────────
_SPIN_PID=""
ui_spin_start() {
  local msg="$1" frames
  case "${UI_SPINNER:-braille}" in
    dots)   frames=('⠂' '⠈' '⠐' '⠠' '⢀' '⡀' '⠄' '⠁') ;;
    line)   frames=('|' '/' '-' '\') ;;
    moon)   frames=('🌑' '🌒' '🌓' '🌔' '🌕' '🌖' '🌗' '🌘') ;;
    bounce) frames=('⠁' '⠂' '⠄' '⠂') ;;
    *)      frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏') ;;
  esac
  ( local i=0
    while true; do
      printf '\r   %s%s%s %s' "$BCYAN" "${frames[$(( i % ${#frames[@]} ))]}" "$RESET" "$msg"
      i=$(( i + 1 )); sleep 0.08
    done ) & _SPIN_PID=$!
  disown 2>/dev/null || true
}
ui_spin_stop() {
  [ -n "$_SPIN_PID" ] && kill "$_SPIN_PID" 2>/dev/null
  _SPIN_PID=""; printf '\r\033[K'
  [ -n "${1:-}" ] && ui_ok "$1"
}

# ── Typewriter ──────────────────────────────────────────────────────────────────
ui_type() {
  local text="$1" delay="${2:-0.015}" i
  for (( i=0; i<${#text}; i++ )); do printf '%s' "${text:$i:1}"; sleep "$delay"; done
  printf '\n'
}

# ── Animated logo reveal (line-by-line fade) ─────────────────────────────────────
ui_reveal() {
  local color="${1:-$BCYAN}"; shift
  local line
  for line in "$@"; do printf '%s%s%s\n' "$color" "$line" "$RESET"; sleep 0.04; done
}

# ── Prompts ──────────────────────────────────────────────────────────────────────
ui_confirm() {
  local q="$1" ans
  printf ' %s?%s %s %s(Y/n)%s ' "$BYELLOW" "$RESET" "$q" "$GRAY" "$RESET"
  read -r ans; case "${ans:-y}" in [Yy]*) return 0 ;; *) return 1 ;; esac
}
ui_ask() { # ui_ask "prompt" [default] -> echoes answer
  local q="$1" def="${2:-}" ans
  if [ -n "$def" ]; then printf ' %s?%s %s %s[%s]%s ' "$BYELLOW" "$RESET" "$q" "$GRAY" "$def" "$RESET"
  else printf ' %s?%s %s ' "$BYELLOW" "$RESET" "$q"; fi
  read -r ans; echo "${ans:-$def}"
}

# ── Arrow-key menu (echoes selected index) ───────────────────────────────────────
ui_menu() {
  local prompt="$1"; shift; local opts=("$@") sel=0 key n=${#opts[@]} i
  printf ' %s%s%s\n' "$BOLD" "$prompt" "$RESET" >&2
  while true; do
    for (( i=0; i<n; i++ )); do
      if [ "$i" -eq "$sel" ]; then printf '   %s❯ %s%s\n' "$BGREEN" "${opts[$i]}" "$RESET" >&2
      else printf '     %s%s%s\n' "$GRAY" "${opts[$i]}" "$RESET" >&2; fi
    done
    read -rsn1 key
    case "$key" in
      $'\x1b') read -rsn2 key; case "$key" in
        '[A') sel=$(( (sel-1+n)%n )) ;; '[B') sel=$(( (sel+1)%n )) ;; esac ;;
      '') echo "$sel"; return 0 ;;
    esac
    printf '\033[%dA' "$n" >&2
  done
}

# ── Section header (gradient) ─────────────────────────────────────────────────────
ui_header() {
  printf '\n'
  gradient "  ▌║█ $1 █║▌" 51 201
  printf '\n'
}
