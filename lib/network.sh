#!/usr/bin/env bash
# lib/network.sh — shared network helpers for clixr

# Get public IP (tries multiple providers)
get_public_ip() {
  local ip
  for url in "https://api.ipify.org" "https://ifconfig.me/ip" "https://icanhazip.com"; do
    ip=$(curl -fsSL --max-time 5 "$url" 2>/dev/null | tr -d '[:space:]')
    [ -n "$ip" ] && { echo "$ip"; return 0; }
  done
  return 1
}

# Get local/LAN IP
get_local_ip() {
  if command -v ip >/dev/null 2>&1; then
    ip route get 1 2>/dev/null | awk '{print $7; exit}'
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig 2>/dev/null | awk '/inet /{print $2}' | grep -v '127.0.0.1' | head -1
  fi
}

# Check if a single TCP port is open: tcp_open <host> <port> [timeout]
tcp_open() {
  local host="$1" port="$2" timeout="${3:-1}"
  if command -v nc >/dev/null 2>&1; then
    nc -z -w "$timeout" "$host" "$port" >/dev/null 2>&1
  else
    timeout "$timeout" bash -c "echo > /dev/tcp/$host/$port" >/dev/null 2>&1
  fi
}

# Resolve hostname to IP
resolve_host() {
  local host="$1"
  if command -v dig >/dev/null 2>&1; then
    dig +short "$host" 2>/dev/null | grep -E '^[0-9.]+$' | head -1
  elif command -v getent >/dev/null 2>&1; then
    getent hosts "$host" 2>/dev/null | awk '{print $1; exit}'
  else
    ping -c1 -W1 "$host" 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p' | head -1
  fi
}

# Common port -> service name
port_service() {
  case "$1" in
    21) echo "FTP" ;; 22) echo "SSH" ;; 23) echo "Telnet" ;;
    25) echo "SMTP" ;; 53) echo "DNS" ;; 80) echo "HTTP" ;;
    110) echo "POP3" ;; 143) echo "IMAP" ;; 443) echo "HTTPS" ;;
    3306) echo "MySQL" ;; 3389) echo "RDP" ;; 5432) echo "PostgreSQL" ;;
    6379) echo "Redis" ;; 8080) echo "HTTP-alt" ;; 27017) echo "MongoDB" ;;
    *) echo "unknown" ;;
  esac
}
