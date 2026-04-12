#!/usr/bin/env bash
# shell/env.sh — Environment variable defaults
#
# Set safe, portable defaults. Override anything in shell/local.sh.

# Locale
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# Preferred editor (override in local.sh)
if command -v nvim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-nvim}"
  export VISUAL="${VISUAL:-nvim}"
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-vim}"
  export VISUAL="${VISUAL:-vim}"
else
  export EDITOR="${EDITOR:-nano}"
  export VISUAL="${VISUAL:-nano}"
fi

# Pager
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R -F -X}"

# History (bash; zsh uses its own settings)
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL="ignoreboth:erasedups"

# XDG base dirs (widely supported default)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
