#!/usr/bin/env bash
# shell/functions.sh — Reusable shell functions

# mkcd — make a directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1" || return 1
}

# up — go up N directories (default: 1)
up() {
  local n="${1:-1}"
  local target=""
  for ((i = 0; i < n; i++)); do
    target="../${target}"
  done
  cd "${target:-.}" || return 1
}

# extract — extract common archive formats
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>" >&2
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "extract: '$1' is not a file" >&2
    return 1
  fi
  case "$1" in
    *.tar.bz2)  tar xjf "$1"    ;;
    *.tar.gz)   tar xzf "$1"    ;;
    *.tar.xz)   tar xJf "$1"    ;;
    *.tar)      tar xf  "$1"    ;;
    *.bz2)      bunzip2     "$1" ;;
    *.gz)       gunzip      "$1" ;;
    *.zip)      unzip       "$1" ;;
    *.Z)        uncompress  "$1" ;;
    *.7z)       7z x        "$1" ;;
    *)          echo "extract: unsupported format '$1'" >&2; return 1 ;;
  esac
}

# confirm — ask for y/n confirmation before running a command
confirm() {
  local prompt="${1:-Are you sure?}"
  read -r -p "$prompt [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

# path_prepend — prepend a directory to PATH if it exists and isn't already there
# (thin wrapper around the logic in shell/path.sh for use after init is sourced)
path_prepend() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}

# find_in — search for a pattern in files under the current directory
find_in() {
  local pattern="${1:?Usage: find_in <pattern> [dir]}"
  local dir="${2:-.}"
  grep -r --color=auto --include="*.sh" --include="*.bash" --include="*.zsh" \
    "$pattern" "$dir"
}

# epoch — print the current Unix epoch timestamp
epoch() { date +%s; }
