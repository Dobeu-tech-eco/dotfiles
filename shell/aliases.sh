#!/usr/bin/env bash
# shell/aliases.sh — Shell aliases

# ─── Navigation ───────────────────────────────────────────────────────────────
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ─── ls / directory listing ───────────────────────────────────────────────────
if ls --color=auto /dev/null >/dev/null 2>&1; then
  # GNU ls
  alias ls="ls --color=auto"
  alias ll="ls -lhF --color=auto"
  alias la="ls -lhAF --color=auto"
else
  # BSD ls (macOS)
  alias ls="ls -G"
  alias ll="ls -lhFG"
  alias la="ls -lhAFG"
fi
alias l="ll"

# ─── File operations ──────────────────────────────────────────────────────────
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias mkdir="mkdir -p"

# ─── grep ─────────────────────────────────────────────────────────────────────
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# ─── Git shorthands ───────────────────────────────────────────────────────────
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate"
alias gp="git push"
alias gpl="git pull"

# ─── Editor ───────────────────────────────────────────────────────────────────
alias e="\$EDITOR"

# ─── Miscellaneous ────────────────────────────────────────────────────────────
alias reload="source \$HOME/.bashrc 2>/dev/null || source \$HOME/.zshrc 2>/dev/null"
alias path='echo -e ${PATH//:/\\n}'
alias now="date '+%Y-%m-%d %H:%M:%S'"
alias week="date +%V"
alias dotfiles='cd "$(dirname "$([ -L "${HOME}/.bashrc" ] && readlink "${HOME}/.bashrc" || echo "${DOTFILES_DIR:-${HOME}/dotfiles}")")"' 2>/dev/null || true
