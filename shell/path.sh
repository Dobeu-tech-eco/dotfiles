#!/usr/bin/env bash
# shell/path.sh — PATH management
#
# Prepend directories to PATH only when they exist and are not already present.

_prepend_path() {
  local dir="$1"
  if [[ -d "$dir" && ":$PATH:" != *":$dir:"* ]]; then
    export PATH="$dir:$PATH"
  fi
}

# User-local binaries
_prepend_path "$HOME/.local/bin"
_prepend_path "$HOME/bin"

# Homebrew (macOS Apple Silicon and Intel)
_prepend_path "/opt/homebrew/bin"
_prepend_path "/usr/local/bin"

unset -f _prepend_path
