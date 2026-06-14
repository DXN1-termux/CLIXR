#!/usr/bin/env bash
# lib/crypto.sh — shared crypto / encoding helpers for clixr

# Internal: pick the right hashing command for an algo, hash from stdin
_hash_stdin() {
  local algo="$1"
  case "$algo" in
    md5)    if command -v md5sum >/dev/null 2>&1; then md5sum; else md5 -q; fi ;;
    sha1)   if command -v sha1sum >/dev/null 2>&1; then sha1sum; else shasum -a 1; fi ;;
    sha256) if command -v sha256sum >/dev/null 2>&1; then sha256sum; else shasum -a 256; fi ;;
    sha512) if command -v sha512sum >/dev/null 2>&1; then sha512sum; else shasum -a 512; fi ;;
    *) return 1 ;;
  esac
}

# Hash a string: hash_str <algo> <string>   (algo: md5|sha1|sha256|sha512)
hash_str() {
  local algo="$1" str="$2"
  printf '%s' "$str" | _hash_stdin "$algo" 2>/dev/null | awk '{print $1}'
}

# Hash a file: hash_file <algo> <path>
hash_file() {
  local algo="$1" file="$2"
  _hash_stdin "$algo" < "$file" 2>/dev/null | awk '{print $1}'
}

# Base64 encode/decode
b64_encode() { printf '%s' "$1" | base64 | tr -d '\n'; }
b64_decode() { printf '%s' "$1" | base64 -d 2>/dev/null; }

# ROT13
rot13() { printf '%s' "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'; }

# AES-256 file encryption via openssl
aes_encrypt() {
  local in="$1" out="$2"
  openssl enc -aes-256-cbc -salt -pbkdf2 -in "$in" -out "$out"
}
aes_decrypt() {
  local in="$1" out="$2"
  openssl enc -d -aes-256-cbc -pbkdf2 -in "$in" -out "$out"
}

# Generate random password: gen_pass <length> [charset]
gen_pass() {
  local len="${1:-20}" charset="${2:-A-Za-z0-9!@#%^&*()_+-=}"
  LC_ALL=C tr -dc "$charset" < /dev/urandom 2>/dev/null | head -c "$len"
  echo
}
