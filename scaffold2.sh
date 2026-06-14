#!/usr/bin/env bash
# scaffold2.sh — second wave of clixr plugins (advanced tools)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
P="$ROOT/plugins"

HEADER='#!/usr/bin/env bash
set -uo pipefail
: "${CLIXR_ROOT:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export CLIXR_LIB="$CLIXR_ROOT/lib"
. "$CLIXR_LIB/colors.sh"; . "$CLIXR_LIB/ui.sh"; . "$CLIXR_LIB/platform.sh"
. "$CLIXR_LIB/utils.sh"; . "$CLIXR_LIB/network.sh"; . "$CLIXR_LIB/crypto.sh"'

mkplugin() {
  local cat="$1" name="$2" desc="$3" body="$4"
  { echo "$HEADER"; echo "# desc: $desc"; echo ""; echo "$body"; } > "$P/$cat/$name"
  chmod +x "$P/$cat/$name"
}

# ─────────── NET ───────────
mkplugin net subdomain "Subdomain enumeration via wordlist" '
domain="${1:?usage: clixr subdomain <domain> [wordlist]}"
words="${2:-}"
list="www mail ftp api dev staging test admin portal vpn ns1 ns2 blog shop app cdn m"
[ -n "$words" ] && [ -f "$words" ] && list="$(cat "$words")"
ui_header "subdomains: $domain"
found=0
for sub in $list; do
  ip=$(resolve_host "$sub.$domain")
  [ -n "$ip" ] && { ui_ok "$sub.$domain → $ip"; found=$((found+1)); }
done
printf "\n"; ui_info "$found subdomain(s) found"'

mkplugin net ssl-check "Inspect a sites SSL/TLS certificate" '
host="${1:?usage: clixr ssl-check <host[:port]>}"
require_cmd openssl || exit 1
port=443; case "$host" in *:*) port="${host#*:}"; host="${host%%:*}";; esac
ui_header "ssl: $host:$port"
echo | openssl s_client -connect "$host:$port" -servername "$host" 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates 2>/dev/null | sed "s/^/  /"'

mkplugin net banner-grab "Grab service banner from a port" '
host="${1:?usage: clixr banner-grab <host> <port>}"; port="${2:?}"
require_cmd nc || exit 1
ui_header "banner: $host:$port"
printf "\r\n" | nc -w3 "$host" "$port" 2>/dev/null | head -5 | sed "s/^/  /"'

mkplugin net traceroute "Trace the route to a host" '
host="${1:?usage: clixr traceroute <host>}"
ui_header "trace: $host"
if has_cmd traceroute; then traceroute -m 20 "$host" 2>/dev/null | sed "s/^/  /"
elif has_cmd tracepath; then tracepath "$host" 2>/dev/null | sed "s/^/  /"
else ui_err "need traceroute or tracepath"; fi'

mkplugin net myip "Detailed public IP + ISP info" '
require_cmd curl || exit 1
ui_header "ip details"
curl -fsSL "https://ipinfo.io/json" 2>/dev/null | sed "s/[{}\",]//g;s/^ *//" | grep -E ":" | sed "s/^/  /"'

# ─────────── SEC ───────────
mkplugin sec wipe "Securely overwrite + delete a file" '
f="${1:?usage: clixr wipe <file>}"
[ -f "$f" ] || die "no such file: $f"
ui_warn "Securely wiping $f"
if ui_confirm "This is irreversible. Continue?"; then
  size=$(wc -c < "$f")
  for pass in 1 2 3; do dd if=/dev/urandom of="$f" bs=1 count="$size" conv=notrunc 2>/dev/null; done
  rm -f "$f"; ui_ok "wiped $f (3 passes)"
else ui_info "cancelled"; fi'

mkplugin sec jwt "Decode a JWT token" '
tok="${1:?usage: clixr jwt <token>}"
ui_header "jwt"
IFS="." read -r h p s <<< "$tok"
pad(){ local d=$(( ${#1} % 4 )); printf "%s" "$1"; [ $d -eq 2 ] && printf "=="; [ $d -eq 3 ] && printf "="; }
ui_step "header";  printf "%s" "$(pad "$h")" | tr "_-" "/+" | base64 -d 2>/dev/null | { has_cmd jq && jq . || cat; }; echo
ui_step "payload"; printf "%s" "$(pad "$p")" | tr "_-" "/+" | base64 -d 2>/dev/null | { has_cmd jq && jq . || cat; }; echo'

mkplugin sec wordlist "Generate a wordlist from base words" '
[ $# -ge 1 ] || die "usage: clixr wordlist word1 word2 ..."
years="2023 2024 2025"; specials="! @ # 123 1 ."
for w in "$@"; do
  echo "$w"; echo "${w^}"; echo "${w^^}"
  for y in $years; do echo "$w$y"; echo "${w^}$y"; done
  for s in $specials; do echo "$w$s"; echo "${w^}$s"; done
done | sort -u'

mkplugin sec vault "Encrypted note vault" '
require_cmd openssl || exit 1
vfile="$(clixr_config_dir)/vault.enc"; mkdir -p "$(clixr_config_dir)"
case "${1:-help}" in
  add)  shift; tmp=$(mktemp); [ -f "$vfile" ] && aes_decrypt "$vfile" "$tmp" 2>/dev/null
        echo "$*" >> "$tmp"; aes_encrypt "$tmp" "$vfile"; rm -f "$tmp"; ui_ok "added" ;;
  show) [ -f "$vfile" ] || die "vault empty"; aes_decrypt "$vfile" /dev/stdout 2>/dev/null ;;
  *)    ui_info "usage: clixr vault add <text> | clixr vault show" ;;
esac'

# ─────────── SYS ───────────
mkplugin sys clean "Clean caches and temp files (dry-run default)" '
ui_header "cleanable space"
targets="$HOME/.cache /tmp"
for t in $targets; do
  [ -d "$t" ] && ui_info "$t — $(du -sh "$t" 2>/dev/null | cut -f1)"
done
if [ "${1:-}" = "--force" ]; then
  if ui_confirm "Delete contents of ~/.cache?"; then rm -rf "$HOME/.cache"/* 2>/dev/null; ui_ok "cleaned"; fi
else ui_warn "dry-run. Re-run with --force to actually clean."; fi'

mkplugin sys logs "Tail system logs with color" '
n="${1:-30}"
ui_header "recent logs"
if has_cmd journalctl; then journalctl -n "$n" --no-pager 2>/dev/null | sed "s/^/  /"
elif [ -f /var/log/syslog ]; then tail -n "$n" /var/log/syslog | sed "s/^/  /"
else ui_warn "no accessible system log"; fi'

mkplugin sys watch "Run a command repeatedly and show output" '
int="${1:-2}"; shift || true
[ $# -ge 1 ] || die "usage: clixr watch <interval> <cmd...>"
trap "clear; exit 0" INT
while true; do clear; ui_header "every ${int}s: $*"; eval "$*"; sleep "$int"; done'

mkplugin sys env "Show environment variables prettily" '
ui_header "environment"
env | sort | awk -F= "{printf \"  \033[96m%-24s\033[0m %s\n\", \$1, substr(\$0, index(\$0,\"=\")+1)}" | grep -iE "${1:-.}"'

# ─────────── DEV ───────────
mkplugin dev port "Find/kill what is using a port" '
port="${1:?usage: clixr port <port> [--kill]}"
ui_header "port $port"
pids=""
if has_cmd lsof; then pids=$(lsof -ti ":$port" 2>/dev/null)
elif has_cmd fuser; then pids=$(fuser "$port/tcp" 2>/dev/null); fi
if [ -z "$pids" ]; then ui_info "nothing on port $port"; exit 0; fi
ui_warn "PIDs using $port: $pids"
[ "${2:-}" = "--kill" ] && { kill -9 $pids 2>/dev/null && ui_ok "killed $pids"; }'

mkplugin dev diff "Pretty side-by-side file diff" '
a="${1:?usage: clixr diff <a> <b>}"; b="${2:?}"
if has_cmd delta; then delta "$a" "$b"
elif has_cmd colordiff; then colordiff -u "$a" "$b"
else diff --color=always -u "$a" "$b" 2>/dev/null || diff -u "$a" "$b"; fi'

mkplugin dev hex "Hex dump of a file or string" '
if [ -f "${1:-}" ]; then xxd "$1" 2>/dev/null || od -A x -t x1z "$1"
else printf "%s" "$*" | { xxd 2>/dev/null || od -A x -t x1z; }; fi'

mkplugin dev todo "Simple CLI todo list" '
f="$(clixr_config_dir)/todo.txt"; mkdir -p "$(clixr_config_dir)"; touch "$f"
case "${1:-list}" in
  add)  shift; echo "[ ] $*" >> "$f"; ui_ok "added" ;;
  done) sed -i "${2:-1}s/\[ \]/[x]/" "$f" 2>/dev/null; ui_ok "marked done" ;;
  clear) : > "$f"; ui_ok "cleared" ;;
  *) ui_header "todo"; nl -ba "$f" | sed "s/^/  /" ;;
esac'

mkplugin dev ssh-keys "List and manage SSH keys" '
ui_header "ssh keys"
for k in "$HOME"/.ssh/*.pub; do
  [ -f "$k" ] || continue
  ui_ok "$(basename "$k")"
  ssh-keygen -lf "$k" 2>/dev/null | sed "s/^/    /"
done
[ -f "$HOME/.ssh/config" ] && { printf "\n"; ui_info "hosts in ~/.ssh/config:"; grep -iE "^host " "$HOME/.ssh/config" | awk "{print \"    \"\$2}"; }'

# ─────────── WEB ───────────
mkplugin web api "Make an API request with pretty output" '
method="${1:?usage: clixr api <GET|POST> <url> [data]}"; url="${2:?}"; data="${3:-}"
require_cmd curl || exit 1
ui_header "$method $url"
if [ -n "$data" ]; then
  curl -fsSL -X "$method" -H "Content-Type: application/json" -d "$data" "$url" 2>/dev/null
else
  curl -fsSL -X "$method" "$url" 2>/dev/null
fi | { has_cmd jq && jq . 2>/dev/null || cat; }'

mkplugin web speed "Test download speed" '
require_cmd curl || exit 1
url="${1:-https://speed.cloudflare.com/__down?bytes=10000000}"
ui_header "speed test"
ui_spin_start "downloading sample..."
t=$( { /usr/bin/time -p curl -fsSL "$url" -o /dev/null; } 2>&1 | awk "/real/{print \$2}" )
ui_spin_stop "done"
ui_info "10MB in ${t:-?}s"'

mkplugin web cert "Generate a self-signed TLS certificate" '
require_cmd openssl || exit 1
cn="${1:-localhost}"
ui_header "self-signed cert for $cn"
openssl req -x509 -newkey rsa:2048 -keyout "$cn.key" -out "$cn.crt" \
  -days 365 -nodes -subj "/CN=$cn" 2>/dev/null \
  && ui_ok "created $cn.key and $cn.crt" || ui_err "failed"'

mkplugin web rss "Read an RSS feed in the terminal" '
url="${1:?usage: clixr rss <feed-url>}"
require_cmd curl || exit 1
ui_header "rss"
curl -fsSL "$url" 2>/dev/null | grep -oE "<title>[^<]*</title>" | sed "s/<[^>]*>//g" | head -15 | sed "s/^/  • /"'

# ─────────── RICE / FUN ───────────
mkplugin rice clock "Big terminal clock" '
trap "tput cnorm 2>/dev/null; clear; exit 0" INT
tput civis 2>/dev/null
while true; do clear; ui_header "$(date +%H:%M:%S)"; printf "  %s%s%s\n" "$GRAY" "$(date +%A,\ %d\ %B\ %Y)" "$RESET"; sleep 1; done'

mkplugin rice pipes "Pipes screensaver" '
cols=$(tput cols 2>/dev/null||echo 80); rows=$(tput lines 2>/dev/null||echo 24)
trap "tput cnorm 2>/dev/null; clear; exit 0" INT
tput civis 2>/dev/null; clear
x=$((cols/2)); y=$((rows/2)); dx=1; dy=0
ch="│─└┐┌┘"
for ((i=0;i<${1:-400};i++)); do
  printf "\033[%d;%dH%s█%s" "$y" "$x" "$(fg256 $((RANDOM%230+16)))" "$RESET"
  case $((RANDOM%8)) in 0) dx=1;dy=0;; 1) dx=-1;dy=0;; 2) dx=0;dy=1;; 3) dx=0;dy=-1;; esac
  x=$((x+dx)); y=$((y+dy))
  [ $x -lt 1 ] && x=$cols; [ $x -gt $cols ] && x=1
  [ $y -lt 1 ] && y=$rows; [ $y -gt $rows ] && y=1
  sleep 0.03
done
tput cnorm 2>/dev/null; clear'

mkplugin fun cowsay "ASCII speech bubble" '
text="${*:-Moo!}"; len=${#text}
top=""; for ((i=0;i<len+2;i++)); do top+="_"; done
bot=""; for ((i=0;i<len+2;i++)); do bot+="-"; done
printf "   %s\n  < %s >\n   %s\n" "$top" "$text" "$bot"
cat <<'"'"'COW'"'"'
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\
                  ||----w |
                  ||     ||
COW'

mkplugin fun ascii "Convert text to ASCII art banner" '
text="${*:-clixr}"
if has_cmd figlet; then figlet "$text"
elif has_cmd toilet; then toilet "$text"
else gradient "### $text ###" 51 201; ui_info "(install figlet for full ASCII art)"; fi'

mkplugin fun weather "Terminal weather report" '
require_cmd curl || exit 1
loc="${1:-}"
curl -fsSL "https://wttr.in/${loc}?format=3" 2>/dev/null || ui_err "weather unavailable"'

echo "wave-2 plugins generated. total: $(find "$P" -type f | wc -l | xargs)"
