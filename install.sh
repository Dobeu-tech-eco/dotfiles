#!/usr/bin/env bash
# install.sh — Bootstrap/apply dobeutech dotfiles
#
# Usage:
#   ./install.sh          — run full setup
#   ./install.sh --dry-run — print what would happen without doing it
#
# The script is idempotent: safe to run multiple times.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false

# ─── Helpers ──────────────────────────────────────────────────────────────────

info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[0;32m[ ok ]\033[0m  %s\n' "$*"; }
warn()  { printf '\033[0;33m[warn]\033[0m  %s\n' "$*"; }
error() { printf '\033[0;31m[err ]\033[0m  %s\n' "$*" >&2; }

link() {
  local src="$1"
  local dst="$2"

  if "$DRY_RUN"; then
    info "(dry-run) would link: $dst -> $src"
    return
  fi

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "already linked: $dst"
    return
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "backing up existing file: $dst -> ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  ln -sf "$src" "$dst"
  ok "linked: $dst -> $src"
}

# ─── Argument parsing ─────────────────────────────────────────────────────────

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) error "Unknown argument: $arg"; exit 1 ;;
  esac
done

if "$DRY_RUN"; then
  warn "Dry-run mode enabled — no files will be changed."
fi

# ─── Prerequisite checks ──────────────────────────────────────────────────────

info "Checking prerequisites..."

if ! command -v git >/dev/null 2>&1; then
  error "git is required but was not found. Please install git first."
  exit 1
fi

ok "Prerequisites satisfied."

# ─── Shell configuration ──────────────────────────────────────────────────────

info "Setting up shell configuration..."

# Source line to add to ~/.bashrc or ~/.zshrc
SHELL_ENTRY="source \"${DOTFILES_DIR}/shell/init.sh\""

setup_shell_rc() {
  local rc_file="$1"
  if [ ! -f "$rc_file" ]; then
    return
  fi
  if grep -qF "$SHELL_ENTRY" "$rc_file" 2>/dev/null; then
    ok "Shell entry already present in $rc_file"
    return
  fi
  if "$DRY_RUN"; then
    info "(dry-run) would append source line to $rc_file"
    return
  fi
  printf '\n# dobeutech dotfiles\n%s\n' "$SHELL_ENTRY" >> "$rc_file"
  ok "Appended source line to $rc_file"
}

setup_shell_rc "$HOME/.bashrc"
setup_shell_rc "$HOME/.zshrc"

# ─── Git configuration ────────────────────────────────────────────────────────

info "Setting up git configuration..."

link "${DOTFILES_DIR}/git/.gitconfig"        "$HOME/.gitconfig"
link "${DOTFILES_DIR}/git/.gitignore_global" "$HOME/.gitignore_global"

# Ensure git uses the global ignore file (idempotent)
if ! "$DRY_RUN"; then
  git config --global core.excludesFile "$HOME/.gitignore_global" 2>/dev/null || true
fi

# ─── Local override scaffold ──────────────────────────────────────────────────

LOCAL_OVERRIDE="${DOTFILES_DIR}/shell/local.sh"
if [ ! -f "$LOCAL_OVERRIDE" ]; then
  if "$DRY_RUN"; then
    info "(dry-run) would create local override scaffold: $LOCAL_OVERRIDE"
  else
    cp "${DOTFILES_DIR}/local.example" "$LOCAL_OVERRIDE"
    ok "Created local override scaffold: $LOCAL_OVERRIDE (not tracked by git)"
  fi
else
  ok "Local override file already exists: $LOCAL_OVERRIDE"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────

printf '\n'
ok "Dotfiles installed successfully."
printf '\n'
info "Next steps:"
info "  1. Edit shell/local.sh for machine-specific settings."
info "  2. Edit git/.gitconfig to set your name and email if not already set."
info "  3. Reload your shell:  source ~/.bashrc  (or ~/.zshrc)"
