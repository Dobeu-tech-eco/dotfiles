#!/usr/bin/env bash
# shell/prompt.sh — Simple, portable shell prompt
#
# Sets PS1 for bash. Zsh users can replace this with a theme of their choice
# in shell/local.sh.

# Only apply in bash; skip silently in zsh (which uses its own prompt system)
if [ -n "$BASH_VERSION" ]; then
  # Colors
  _c_reset='\[\033[0m\]'
  _c_green='\[\033[0;32m\]'
  _c_cyan='\[\033[0;36m\]'
  _c_yellow='\[\033[0;33m\]'
  _c_red='\[\033[0;31m\]'

  # Git branch in prompt
  _git_branch() {
    local branch
    branch="$(git symbolic-ref --short HEAD 2>/dev/null)" || return
    printf ' (%s)' "$branch"
  }

  PS1="${_c_green}\u${_c_reset}@${_c_cyan}\h${_c_reset}:${_c_yellow}\w${_c_reset}"
  PS1+='$(_git_branch)'
  PS1+="\$ "
  export PS1

  unset _c_reset _c_green _c_cyan _c_yellow _c_red
fi
