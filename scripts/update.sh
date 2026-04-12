#!/usr/bin/env bash
# scripts/update.sh — Pull the latest dotfiles and re-apply them
#
# Safe to run at any time. It pulls the current branch from origin,
# then re-runs install.sh.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[0;32m[ ok ]\033[0m  %s\n' "$*"; }
error() { printf '\033[0;31m[err ]\033[0m  %s\n' "$*" >&2; }

info "Updating dotfiles from origin..."

if ! git -C "$DOTFILES_DIR" fetch --quiet origin; then
  error "git fetch failed. Check your network and remote settings."
  exit 1
fi

BRANCH="$(git -C "$DOTFILES_DIR" symbolic-ref --short HEAD 2>/dev/null || echo main)"

if git -C "$DOTFILES_DIR" rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
  git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH"
  ok "Repository updated to latest commit."
else
  info "No remote tracking branch found for '$BRANCH'. Skipping pull."
fi

info "Re-applying dotfiles..."
bash "${DOTFILES_DIR}/install.sh"

ok "Dotfiles updated and re-applied."
