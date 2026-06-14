#!/usr/bin/env bash
# scaffold.sh — generates clixr plugins, themes, and helper scripts.
# Each plugin sources the shared libs and is a standalone executable.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P="$ROOT/plugins"
mkdir -p "$P"/{net,sec,sys,dev,web,rice,fun} "$ROOT/themes" "$ROOT/docs"

# Common header sourced by every plugin
HEADER='#!/usr/bin/env bash
set -uo pipefail
: "${CLIXR_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export CLIXR_LIB="$CLIXR_ROOT/lib"
. "$CLIXR_LIB/colors.sh"; . "$CLIXR_LIB/ui.sh"; . "$CLIXR_LIB/platform.sh"
. "$CLIXR_LIB/utils.sh"; . "$CLIXR_LIB/network.sh"; . "$CLIXR_LIB/crypto.sh"'

mkplugin() { # mkplugin <category> <name> <desc> <body>
  local cat="$1" name="$2" desc="$3" body="$4"
  {
    echo "$HEADER"
    echo "# desc: $desc"
    echo ""
    echo "$body"
  } > "$P/$cat/$name"
  chmod +x "$P/$cat/$name"
}

# ─────────────────────────── RICE ───────────────────────────
mkplugin rice colortest "Show all 256 terminal colors" '
printf "\n  Standard & bright (0-15):\n  "
for i in $(seq 0 15); do printf "%s %3d %s" "$(bg256 "$i")" "$i" "$RESET"; [ $(((i+1)%8)) -eq 0 ] && printf "\n  "; done
printf "\n\n  256 color cube:\n  "
for i in $(seq 16 231); do printf "%s %3d%s" "$(bg256 "$i")" "$i" "$RESET"; [ $(((i-15)%12)) -eq 0 ] && printf "\n  "; done
printf "\n\n  Grayscale:\n  "
for i in $(seq 232 255); do printf "%s %3d%s" "$(bg256 "$i")" "$i" "$RESET"; done
printf "\n\n"'

mkplugin rice matrix "Matrix digital rain animation" '
cols=$(tput cols 2>/dev/null || echo 80)
trap "tput cnorm 2>/dev/null; printf %s%s \"$RESET\" \"\"; clear; exit 0" INT
tput civis 2>/dev/null; clear
chars="01ｱｲｳｴｵｶｷｸ#$%&"
declare -a drop
for ((c=0;c<cols;c++)); do drop[$c]=$((RANDOM % 24)); done
for ((frame=0; frame<${1:-200}; frame++)); do
  line=""
  for ((c=0;c<cols;c++)); do
    ch="${chars:$((RANDOM % ${#chars})):1}"
    printf "\033[%d;%dH%s%s%s" "${drop[$c]}" "$c" "$(fg256 46)" "$ch" "$RESET"
    drop[$c]=$(( ${drop[$c]} + 1 )); [ ${drop[$c]} -gt 24 ] && drop[$c]=0
  done
  sleep 0.05
done
tput cnorm 2>/dev/null; clear'

mkplugin rice theme "Switch terminal color theme" '
themedir="$CLIXR_ROOT/themes"
if [ -z "${1:-}" ]; then
  ui_header "available themes"
  for t in "$themedir"/*.theme; do [ -f "$t" ] && printf "  %s•%s %s\n" "$BGREEN" "$RESET" "$(basename "$t" .theme)"; done
  cur=$(config_get theme 2>/dev/null || echo none)
  printf "\n  current: %s%s%s\n" "$BCYAN" "$cur" "$RESET"
  exit 0
fi
if [ -f "$themedir/$1.theme" ]; then
  config_set theme "$1"
  ui_ok "Theme set to $1 (restart shell or re-source to apply)"
  ui_info "Add to your shell rc: source $themedir/$1.theme"
else
  ui_err "Theme not found: $1"
fi'

mkplugin rice fetch "Pretty system info fetch (neofetch-style)" '
os=$(detect_os); arch=$(detect_arch); sh=$(detect_shell)
host=$(hostname 2>/dev/null || echo unknown)
me="${USER:-$(whoami)}"
up=$(uptime 2>/dev/null | sed "s/.*up //;s/,.*user.*//" | xargs || echo "?")
c="$BCYAN"; g="$BGREEN"; r="$RESET"
printf "\n"
printf "  %s   .--.    %s   %s%s@%s%s\n"        "$c" "$r" "$g" "$me" "$host" "$r"
printf "  %s  |o_o |   %s   %s----------%s\n"   "$c" "$r" "$GRAY" "$r"
printf "  %s  |:_/ |   %s   %sos%s     %s\n"     "$c" "$r" "$c" "$r" "$os"
printf "  %s //   \\\\ \\\\  %s   %sarch%s   %s\n"   "$c" "$r" "$c" "$r" "$arch"
printf "  %s(|     | ) %s   %sshell%s  %s\n"     "$c" "$r" "$c" "$r" "$sh"
printf "  %s\\\\___)=(___/%s  %suptime%s %s\n\n"  "$c" "$r" "$c" "$r" "$up"'

mkplugin rice banner "Generate a text banner" '
text="${*:-clixr}"
gradient ">>> $text <<<" 51 201'

# ─────────────────────────── SYS ───────────────────────────
mkplugin sys sysinfo "Full system information" '
print_kv(){ printf "  %s%-12s%s %s\n" "$BCYAN" "$1" "$RESET" "$2"; }
ui_header "system info"
print_kv "User"    "${USER:-$(whoami)}"
print_kv "Host"    "$(hostname 2>/dev/null)"
print_kv "OS"      "$(detect_os)"
print_kv "Arch"    "$(detect_arch)"
print_kv "Kernel"  "$(uname -r 2>/dev/null)"
print_kv "Shell"   "$(detect_shell)"
print_kv "Term"    "$(detect_term)"
print_kv "Uptime"  "$(uptime 2>/dev/null | sed "s/.*up //;s/,.*user.*//" | xargs)"
if has_cmd free; then print_kv "Memory" "$(free -h 2>/dev/null | awk "/Mem:/{print \$3\" / \"\$2}")"; fi
print_kv "Disk"    "$(df -h . 2>/dev/null | awk "NR==2{print \$3\" / \"\$2\" (\"\$5\")\"}")"
printf "\n"'

mkplugin sys procs "Top processes by CPU/memory" '
ui_header "top processes"
printf "  %s%-8s %-6s %-6s %s%s\n" "$BOLD" "PID" "CPU%" "MEM%" "COMMAND" "$RESET"
ps -eo pid,pcpu,pmem,comm 2>/dev/null | sort -k2 -rn | head -"${1:-10}" | \
  awk "{printf \"  %-8s %-6s %-6s %s\n\", \$1, \$2, \$3, \$4}"'

mkplugin sys disk "Disk usage overview" '
ui_header "disk usage"
df -h 2>/dev/null | awk "NR==1{print \"  \"\$0} NR>1 && \$1!~/loop/{print \"  \"\$0}"'

mkplugin sys cpu "CPU and memory snapshot" '
ui_header "cpu / memory"
if has_cmd nproc; then ui_info "Cores: $(nproc)"; fi
[ -f /proc/loadavg ] && ui_info "Load: $(cut -d" " -f1-3 /proc/loadavg)"
if has_cmd free; then free -h 2>/dev/null | awk "NR<=2{print \"  \"\$0}"; fi'

mkplugin sys ports "Show what is listening on which ports" '
ui_header "listening ports"
if has_cmd ss; then ss -tulnp 2>/dev/null | head -30
elif has_cmd netstat; then netstat -tulnp 2>/dev/null | head -30
else ui_err "need ss or netstat"; fi'

# ─────────────────────────── NET ───────────────────────────
mkplugin net portscan "Fast TCP port scanner" '
host="${1:-localhost}"; range="${2:-1-1024}"
start="${range%-*}"; end="${range#*-}"
ui_header "scanning $host ($start-$end)"
open=0
for ((p=start; p<=end; p++)); do
  if tcp_open "$host" "$p" 1; then
    ui_ok "$p open  ($(port_service "$p"))"; open=$((open+1))
  fi
done
printf "\n"; ui_info "$open open port(s) found"'

mkplugin net iplookup "Public IP + geolocation lookup" '
ip="${1:-}"
if [ -z "$ip" ]; then ip=$(get_public_ip); ui_info "Your public IP: $ip"; fi
require_cmd curl || exit 1
ui_header "ip info: $ip"
curl -fsSL "https://ipinfo.io/$ip/json" 2>/dev/null | sed "s/[{}\",]//g;s/^ *//" | grep -E ":" | sed "s/^/  /"'

mkplugin net dns "DNS lookup for a host" '
host="${1:?usage: clixr dns <host>}"
ui_header "dns: $host"
if has_cmd dig; then dig +short "$host" | sed "s/^/  /"
else ui_info "$(resolve_host "$host")"; fi'

mkplugin net ping-sweep "Discover live hosts on a /24 subnet" '
base="${1:?usage: clixr ping-sweep 192.168.1}"
ui_header "ping sweep: $base.0/24"
for i in $(seq 1 254); do
  ( ping -c1 -W1 "$base.$i" >/dev/null 2>&1 && ui_ok "$base.$i is up" ) &
done; wait'

mkplugin net http-headers "Inspect HTTP response headers" '
url="${1:?usage: clixr http-headers <url>}"
require_cmd curl || exit 1
ui_header "headers: $url"
curl -fsSI "$url" 2>/dev/null | sed "s/^/  /"'

# ─────────────────────────── SEC ───────────────────────────
mkplugin sec passgen "Generate a strong random password" '
len="${1:-20}"
ui_header "password ($len chars)"
printf "  %s%s%s\n\n" "$BGREEN" "$(gen_pass "$len")" "$RESET"'

mkplugin sec hash "Hash a string or file" '
algo="${1:-sha256}"; target="${2:?usage: clixr hash <algo> <string|file>}"
if [ -f "$target" ]; then h=$(hash_file "$algo" "$target"); else h=$(hash_str "$algo" "$target"); fi
printf "  %s%s%s  %s\n" "$BGREEN" "$algo" "$RESET" "$h"'

mkplugin sec b64 "Base64 encode/decode" '
mode="${1:?usage: clixr b64 enc|dec <string>}"; shift
case "$mode" in
  enc|e) b64_encode "$*"; echo ;;
  dec|d) b64_decode "$*"; echo ;;
  *) ui_err "mode must be enc or dec" ;;
esac'

mkplugin sec encrypt "AES-256 encrypt/decrypt a file" '
require_cmd openssl || exit 1
mode="${1:?usage: clixr encrypt enc|dec <in> <out>}"; in="${2:?}"; out="${3:?}"
case "$mode" in
  enc) aes_encrypt "$in" "$out" && ui_ok "encrypted → $out" ;;
  dec) aes_decrypt "$in" "$out" && ui_ok "decrypted → $out" ;;
  *) ui_err "mode must be enc or dec" ;;
esac'

mkplugin sec rot13 "ROT13 cipher" 'rot13 "$*"; echo'

# ─────────────────────────── DEV ───────────────────────────
mkplugin dev serve "Quick local HTTP server" '
port="${1:-8000}"
ui_header "serving $(pwd) on :$port"
ip=$(get_local_ip); [ -n "$ip" ] && ui_info "LAN: http://$ip:$port"
if has_cmd python3; then python3 -m http.server "$port"
elif has_cmd python; then python -m SimpleHTTPServer "$port"
else ui_err "need python"; fi'

mkplugin dev json "Pretty-print / validate JSON" '
if has_cmd jq; then
  if [ -f "${1:-}" ]; then jq . "$1"; else printf "%s" "$*" | jq .; fi
elif has_cmd python3; then
  if [ -f "${1:-}" ]; then python3 -m json.tool "$1"; else printf "%s" "$*" | python3 -m json.tool; fi
else ui_err "need jq or python3"; fi'

mkplugin dev gitx "Git power shortcuts (stats, quick commit)" '
sub="${1:-stats}"; shift || true
case "$sub" in
  stats)
    ui_header "git stats"
    ui_info "Branch:  $(git branch --show-current 2>/dev/null)"
    ui_info "Commits: $(git rev-list --count HEAD 2>/dev/null)"
    ui_info "Authors: $(git shortlog -sn 2>/dev/null | wc -l | xargs)"
    git log --oneline -5 2>/dev/null | sed "s/^/  /" ;;
  save) git add -A && git commit -m "${*:-wip}" ;;
  undo) git reset --soft HEAD~1 && ui_ok "undid last commit (kept changes)" ;;
  *) ui_err "usage: clixr gitx stats|save|undo" ;;
esac'

mkplugin dev qr "Generate a QR code in the terminal" '
data="${*:?usage: clixr qr <text|url>}"
if has_cmd qrencode; then qrencode -t ANSIUTF8 "$data"
else
  require_cmd curl || exit 1
  curl -fsSL "https://api.qrserver.com/v1/create-qr-code/?data=$(printf %s "$data" | sed "s/ /%20/g")&size=200x200" -o /tmp/clixr_qr.png 2>/dev/null \
    && ui_ok "QR saved to /tmp/clixr_qr.png" || ui_err "failed"
fi'

mkplugin dev regex "Test a regex against input" '
pat="${1:?usage: clixr regex <pattern> <string>}"; shift
printf "%s\n" "$*" | grep -E --color=always "$pat" && ui_ok "match" || ui_warn "no match"'

# ─────────────────────────── WEB ───────────────────────────
mkplugin web ip "Show your public IP and info" '
require_cmd curl || exit 1
ui_header "your ip"
ui_info "Public:  $(get_public_ip)"
ui_info "Local:   $(get_local_ip)"'

mkplugin web dl "Simple download with progress" '
url="${1:?usage: clixr dl <url> [out]}"; out="${2:-$(basename "$url")}"
require_cmd curl || exit 1
ui_info "downloading → $out"
curl -fL --progress-bar "$url" -o "$out" && ui_ok "saved $out"'

mkplugin web whois "Domain WHOIS lookup" '
d="${1:?usage: clixr whois <domain>}"
if has_cmd whois; then whois "$d" | sed "s/^/  /" | head -40
else require_cmd curl && curl -fsSL "https://rdap.org/domain/$d" 2>/dev/null; fi'

mkplugin web headers "Analyze security headers of a site" '
url="${1:?usage: clixr headers <url>}"
require_cmd curl || exit 1
ui_header "security headers: $url"
h=$(curl -fsSI "$url" 2>/dev/null)
for hdr in Strict-Transport-Security Content-Security-Policy X-Frame-Options X-Content-Type-Options Referrer-Policy; do
  if printf "%s" "$h" | grep -qi "^$hdr"; then ui_ok "$hdr"; else ui_warn "$hdr missing"; fi
done'

mkplugin web paste "Upload stdin/file to a pastebin" '
require_cmd curl || exit 1
if [ -f "${1:-}" ]; then content=$(cat "$1"); else content=$(cat); fi
url=$(printf "%s" "$content" | curl -fsSL --data-binary @- https://0x0.st 2>/dev/null)
[ -n "$url" ] && ui_ok "$url" || ui_err "upload failed"'

# ─────────────────────────── FUN ───────────────────────────
mkplugin fun hack "Fake hollywood hacking animation" '
clear; lines="${1:-40}"
chars="0123456789abcdef ACCESS GRANTED DENIED root@ sudo rm exploit payload 0x"
for ((i=0;i<lines;i++)); do
  s=""; for ((j=0;j<RANDOM%60+20;j++)); do s+="${chars:$((RANDOM%${#chars})):1}"; done
  printf "%s%s%s\n" "$(fg256 46)" "$s" "$RESET"; sleep 0.05
done
ui_box "ACCESS GRANTED" "" "  Welcome, operator." ""'

mkplugin fun glitch "Glitch-ify text" '
text="${*:-clixr}"
for ((i=0;i<8;i++)); do
  out=""; for ((j=0;j<${#text};j++)); do
    if [ $((RANDOM%3)) -eq 0 ]; then out+="${text:$((RANDOM%${#text})):1}"; else out+="${text:$j:1}"; fi
  done
  printf "\r%s%s%s" "$BRED" "$out" "$RESET"; sleep 0.08
done
printf "\r%s%s%s\n" "$BGREEN" "$text" "$RESET"'

mkplugin fun fortune "Random hacker wisdom" '
quotes=(
"There is no patch for human stupidity."
"The quieter you become, the more you are able to hear."
"Hack the planet!"
"It is not a bug, it is an undocumented feature."
"sudo make me a sandwich."
"Talk is cheap. Show me the code. — Linus Torvalds"
"Premature optimization is the root of all evil."
"rm -rf / is not a backup strategy."
)
printf "\n  %s\"%s\"%s\n\n" "$BCYAN" "${quotes[$((RANDOM % ${#quotes[@]}))]}" "$RESET"'

mkplugin fun rainbow "Rainbow-ify text" 'rainbow "${*:-clixr}"'

echo "plugins generated: $(find "$P" -type f | wc -l | xargs)"
