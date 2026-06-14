#!/usr/bin/env bash
# lib/colors.sh — ANSI 256-color + truecolor helpers for clixr

# Base escape
ESC=$'\033'
RESET="${ESC}[0m"

# Styles
BOLD="${ESC}[1m"
DIM="${ESC}[2m"
ITALIC="${ESC}[3m"
UNDERLINE="${ESC}[4m"
BLINK="${ESC}[5m"
REVERSE="${ESC}[7m"
STRIKE="${ESC}[9m"

# Standard foreground colors
BLACK="${ESC}[30m"
RED="${ESC}[31m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m"
WHITE="${ESC}[37m"
GRAY="${ESC}[90m"

# Bright foreground colors
BRED="${ESC}[91m"
BGREEN="${ESC}[92m"
BYELLOW="${ESC}[93m"
BBLUE="${ESC}[94m"
BMAGENTA="${ESC}[95m"
BCYAN="${ESC}[96m"
BWHITE="${ESC}[97m"

# Background colors
BG_BLACK="${ESC}[40m"
BG_RED="${ESC}[41m"
BG_GREEN="${ESC}[42m"
BG_YELLOW="${ESC}[43m"
BG_BLUE="${ESC}[44m"
BG_MAGENTA="${ESC}[45m"
BG_CYAN="${ESC}[46m"
BG_WHITE="${ESC}[47m"

# 256-color foreground: fg256 <0-255>
fg256() { printf '%s[38;5;%sm' "$ESC" "$1"; }
# 256-color background: bg256 <0-255>
bg256() { printf '%s[48;5;%sm' "$ESC" "$1"; }

# Truecolor foreground: fgrgb <r> <g> <b>
fgrgb() { printf '%s[38;2;%s;%s;%sm' "$ESC" "$1" "$2" "$3"; }
# Truecolor background: bgrgb <r> <g> <b>
bgrgb() { printf '%s[48;2;%s;%s;%sm' "$ESC" "$1" "$2" "$3"; }

# Rainbow text: rainbow "string"
rainbow() {
  local text="$1" i ch
  local colors=(196 202 208 214 220 226 190 154 118 82 46 47 48 49 50 51 45 39 33 27 21 57 93 129 165 201)
  local n=${#colors[@]}
  for (( i=0; i<${#text}; i++ )); do
    ch="${text:$i:1}"
    printf '%s%s' "$(fg256 "${colors[$(( i % n ))]}")" "$ch"
  done
  printf '%s\n' "$RESET"
}

# Gradient text between two 256-colors: gradient "string" <start> <end>
gradient() {
  local text="$1" start="${2:-39}" end="${3:-201}" i ch
  local len=${#text}
  [ "$len" -eq 0 ] && return
  for (( i=0; i<len; i++ )); do
    ch="${text:$i:1}"
    local c=$(( start + (end - start) * i / (len > 1 ? len - 1 : 1) ))
    printf '%s%s' "$(fg256 "$c")" "$ch"
  done
  printf '%s\n' "$RESET"
}

# True if terminal supports color
supports_color() {
  [ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ] && [ -z "${NO_COLOR:-}" ]
}

# Multi-stop gradient across an array of 256 colors: mgradient "text" c1 c2 c3...
mgradient() {
  local text="$1"; shift
  local stops=("$@") len=${#text} nseg=$(( ${#stops[@]} - 1 )) i
  [ "$len" -eq 0 ] && return
  [ "$nseg" -lt 1 ] && { printf '%s%s%s\n' "$(fg256 "${stops[0]}")" "$text" "$RESET"; return; }
  for (( i=0; i<len; i++ )); do
    local pos=$(( i * nseg * 100 / (len > 1 ? len - 1 : 1) ))
    local seg=$(( pos / 100 )); [ "$seg" -ge "$nseg" ] && seg=$(( nseg - 1 ))
    local frac=$(( pos % 100 ))
    local a=${stops[$seg]} b=${stops[$(( seg + 1 ))]}
    local c=$(( a + (b - a) * frac / 100 ))
    printf '%s%s' "$(fg256 "$c")" "${text:$i:1}"
  done
  printf '%s\n' "$RESET"
}

# Convert a hex color (#rrggbb or rrggbb) to a truecolor fg escape: fghex "#ff2e97"
fghex() {
  local h="${1#\#}"
  local r=$(( 16#${h:0:2} )) g=$(( 16#${h:2:2} )) b=$(( 16#${h:4:2} ))
  fgrgb "$r" "$g" "$b"
}
bghex() {
  local h="${1#\#}"
  local r=$(( 16#${h:0:2} )) g=$(( 16#${h:2:2} )) b=$(( 16#${h:4:2} ))
  bgrgb "$r" "$g" "$b"
}

# Brand palette — used consistently across clixr output
CX_PRIMARY=51      # cyan
CX_ACCENT=201      # magenta
CX_OK=46           # green
CX_WARN=220        # amber
CX_ERR=196         # red
CX_MUTED=244       # gray

# Colorize a single token: paint <256color> "text"
paint() { printf '%s%s%s' "$(fg256 "$1")" "$2" "$RESET"; }
