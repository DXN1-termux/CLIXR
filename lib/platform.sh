#!/usr/bin/env bash
# lib/platform.sh — OS / arch / environment detection for clixr

# Detect operating system: termux | macos | linux | wsl | windows | unknown
detect_os() {
  if [ -n "${PREFIX:-}" ] && case "$PREFIX" in *com.termux*) true ;; *) false ;; esac; then
    echo "termux"; return
  fi
  case "$(uname -s 2>/dev/null)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

# Detect CPU architecture
detect_arch() {
  case "$(uname -m 2>/dev/null)" in
    x86_64|amd64) echo "x86_64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l|armv7) echo "armv7" ;;
    i386|i686) echo "x86" ;;
    *) uname -m 2>/dev/null || echo "unknown" ;;
  esac
}

# Detect the current shell name
detect_shell() {
  basename "${SHELL:-/bin/sh}"
}

# Detect the terminal emulator
detect_term() {
  echo "${TERM_PROGRAM:-${TERMUX_VERSION:+Termux}${TERMUX_VERSION:-${TERM:-unknown}}}"
}

# Check if a command exists
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Return the platform-appropriate package install command for a given package
pkg_install_cmd() {
  case "$(detect_os)" in
    termux) echo "pkg install -y $1" ;;
    macos)  echo "brew install $1" ;;
    linux|wsl)
      if has_cmd apt-get; then echo "sudo apt-get install -y $1"
      elif has_cmd dnf; then echo "sudo dnf install -y $1"
      elif has_cmd pacman; then echo "sudo pacman -S --noconfirm $1"
      elif has_cmd apk; then echo "sudo apk add $1"
      else echo ""; fi ;;
    *) echo "" ;;
  esac
}

# Best path to install user binaries
bin_install_dir() {
  case "$(detect_os)" in
    termux) echo "$PREFIX/bin" ;;
    *) echo "$HOME/.local/bin" ;;
  esac
}
