#!/usr/bin/env bash
# scripts/validate.sh — Validate the dotfiles repository
#
# Checks:
#   1. Shell script syntax (bash -n)
#   2. Executable permission on scripts that need it
#   3. No secrets accidentally tracked by git
#   4. No broken symlinks in common locations
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=1
status=0

pass() { printf '\033[0;32m[PASS]\033[0m %s\n' "$*"; }
fail() { printf '\033[0;31m[FAIL]\033[0m %s\n' "$*" >&2; status=1; }
info() { printf '\033[0;34m[INFO]\033[0m %s\n' "$*"; }

# ─── 1. Shell syntax check ────────────────────────────────────────────────────

info "Checking shell script syntax..."

while IFS= read -r -d '' f; do
  if bash -n "$f" 2>/dev/null; then
    pass "syntax ok: $f"
  else
    fail "syntax error: $f"
  fi
done < <(find "$DOTFILES_DIR" \
  -not -path '*/.git/*' \
  -not -path '*/.agent/*' \
  \( -name '*.sh' -o -name '*.bash' \) \
  -print0)

# ─── 2. Executable permission check ──────────────────────────────────────────

info "Checking executable permissions on entry-point scripts..."

for script in \
  "$DOTFILES_DIR/install.sh" \
  "$DOTFILES_DIR/scripts/validate.sh" \
  "$DOTFILES_DIR/scripts/update.sh"; do
  if [ -f "$script" ]; then
    if [ -x "$script" ]; then
      pass "executable: $script"
    else
      fail "not executable: $script (run: chmod +x $script)"
    fi
  fi
done

# ─── 3. Secret file guard ─────────────────────────────────────────────────────

info "Checking for accidentally tracked secret files..."

SUSPICIOUS_PATTERNS=(
  "*.pem"
  "*.key"
  "*.p12"
  "*.cert"
  ".env"
  ".secrets"
  ".netrc"
  ".npmrc"
  ".pypirc"
  "*.token"
  "local.sh"
  ".gitconfig.local"
)

for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
  # Check if any tracked file matches the pattern
  if git -C "$DOTFILES_DIR" ls-files -- "$pattern" 2>/dev/null | grep -q .; then
    fail "Potentially sensitive file is tracked by git: $pattern"
  fi
done
pass "No obviously sensitive files appear to be tracked."

# ─── 4. No broken symlinks in home ────────────────────────────────────────────

info "Checking for broken symlinks installed by dotfiles..."

for link in "$HOME/.gitconfig" "$HOME/.gitignore_global"; do
  if [ -L "$link" ]; then
    if [ -e "$link" ]; then
      pass "symlink ok: $link"
    else
      fail "broken symlink: $link"
    fi
  else
    info "not yet installed (run install.sh): $link"
  fi
done

# ─── Result ───────────────────────────────────────────────────────────────────

echo ""
if [ "$status" -eq 0 ]; then
  printf '\033[0;32mAll checks passed.\033[0m\n'
else
  printf '\033[0;31mSome checks failed. See output above.\033[0m\n'
fi

exit "$status"
