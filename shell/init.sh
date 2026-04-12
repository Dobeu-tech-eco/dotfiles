#!/usr/bin/env bash
# shell/init.sh — Main entry point for dobeutech shell configuration
#
# Source this file from ~/.bashrc or ~/.zshrc.
# It loads all shell configuration layers in the correct order.

DOTFILES_SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

_source_if_exists() {
  [ -f "$1" ] && source "$1"
}

_source_if_exists "${DOTFILES_SHELL_DIR}/env.sh"
_source_if_exists "${DOTFILES_SHELL_DIR}/path.sh"
_source_if_exists "${DOTFILES_SHELL_DIR}/aliases.sh"
_source_if_exists "${DOTFILES_SHELL_DIR}/functions.sh"
_source_if_exists "${DOTFILES_SHELL_DIR}/prompt.sh"

# Load machine-local overrides last so they can override anything above.
_source_if_exists "${DOTFILES_SHELL_DIR}/local.sh"
