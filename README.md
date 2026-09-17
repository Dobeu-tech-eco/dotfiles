# dotfiles

Personal dotfiles for **dobeutech** — portable shell, git, and tooling configuration managed as a versioned repository.

---

## Contents

- [Purpose](#purpose)
- [Repository structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Local overrides](#local-overrides)
- [What must never be committed](#what-must-never-be-committed)
- [Extending the repo](#extending-the-repo)
- [Validation](#validation)
- [Updating](#updating)
- [Reference documentation](#reference-documentation)

---

## Purpose

This repository provides a minimal, maintainable starting point for managing dotfiles under version control. It cleanly separates:

| Layer | Location | Tracked? |
|---|---|---|
| Shared shell config | `shell/` | ✅ yes |
| Shared git config | `git/` | ✅ yes |
| Utility scripts | `scripts/` | ✅ yes |
| Machine-local overrides | `shell/local.sh` | ❌ no (gitignored) |
| Private git identity | `~/.gitconfig.local` | ❌ no (gitignored) |
| Secrets & credentials | anywhere | ❌ never |

---

## Repository structure

```
dotfiles/
├── .agent/                    # Agent checkpoint artifacts (progress, tasks, state)
├── .devcontainer/             # Reproducible development container definition
├── .ona/                      # Ona task and service automation
├── .gitignore                 # Ignores secrets, local overrides, editor noise
├── docs/
│   └── reference.md           # Complete shell and automation API reference
├── git/
│   ├── .gitconfig             # Shared git settings and aliases (symlinked to ~/.gitconfig)
│   ├── .gitconfig.local.example  # Template for private name/email/key settings
│   └── .gitignore_global      # Global ignore rules (symlinked to ~/.gitignore_global)
├── local.example              # Template for shell/local.sh
├── install.sh                 # Bootstrap/apply script
├── scripts/
│   ├── update.sh              # Pull latest and re-apply
│   └── validate.sh            # Sanity checks for the repo
├── shell/
│   ├── init.sh                # Entry point — source this from ~/.bashrc or ~/.zshrc
│   ├── env.sh                 # Environment variable defaults
│   ├── path.sh                # Safe PATH management
│   ├── aliases.sh             # Shell aliases
│   ├── functions.sh           # Reusable shell functions
│   └── prompt.sh              # Minimal bash prompt with git branch
├── README.md                  # Installation and maintenance guide
└── spec.md                    # Repository setup specification
```

---

## Prerequisites

- **bash** ≥ 4 or **zsh** (for the shell configuration)
- **git** (required by install.sh and validate.sh)
- A Unix-like system (Linux, macOS)

---

## Installation

1. **Clone the repository**

   ```sh
   git clone https://github.com/Dobeu-tech-eco/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Preview what will happen (dry run)**

   ```sh
   bash install.sh --dry-run
   ```

3. **Apply**

   ```sh
   bash install.sh
   ```

   The installer will:
   - Append a `source` line to `~/.bashrc` and/or `~/.zshrc`
   - Symlink `git/.gitconfig` → `~/.gitconfig`
   - Symlink `git/.gitignore_global` → `~/.gitignore_global`
   - Create `shell/local.sh` from `local.example` (if it doesn't already exist)

4. **Set your git identity**

   Create `~/.gitconfig.local` (which is never tracked):

   ```sh
   cp git/.gitconfig.local.example ~/.gitconfig.local
   # then edit ~/.gitconfig.local with your name, email, and optional GPG key
   ```

5. **Reload your shell**

   ```sh
   source ~/.bashrc   # or: source ~/.zshrc
   ```

The installer is **idempotent** — safe to run multiple times.

---

## Local overrides

`shell/local.sh` is loaded last by `shell/init.sh` and is the correct place for:

- Machine-specific PATH entries
- Private environment variables (API keys, tokens)
- Work or corporate proxy settings
- Personal aliases that belong only on one machine

This file is listed in `.gitignore` and will never be committed.

See `local.example` for an annotated template.

---

## What must never be committed

These files must stay out of git — they are already covered by `.gitignore`:

| File / pattern | Reason |
|---|---|
| `shell/local.sh` | Machine-specific settings |
| `~/.gitconfig.local` | Private git identity |
| `*.pem`, `*.key`, `*.cert` | TLS/SSH private material |
| `.env`, `.env.*` | Application secrets |
| `.secrets`, `secrets/` | Any secrets directory |
| `*.token` | API tokens |

If you accidentally stage one of these, remove it with:

```sh
git rm --cached <file>
```

---

## Extending the repo

- **New shell helpers**: add functions to `shell/functions.sh` or create a new `shell/<topic>.sh` and source it from `shell/init.sh`.
- **New aliases**: add to `shell/aliases.sh`.
- **New git aliases**: add to the `[alias]` section of `git/.gitconfig`.
- **App config** (e.g. `tmux`, `vim`): add a directory at the top level (e.g. `vim/`) with the relevant config files and symlink them from `install.sh`.
- **Machine-local overrides**: always go in `shell/local.sh`.

Keep scripts short, readable, and defensive (`set -euo pipefail`).

---

## Validation

```sh
bash scripts/validate.sh
```

Checks:
1. Shell syntax (`bash -n`) on every `*.sh` file
2. Executable permissions on entry-point scripts
3. No accidentally tracked secret files
4. No broken symlinks for installed dotfiles

All checks should pass before committing.

---

## Updating

To pull the latest changes and re-apply:

```sh
bash scripts/update.sh
```

---

## Reference documentation

See [Shell and Automation Reference](docs/reference.md) for function signatures,
parameters, return statuses, side effects, aliases, environment variables, and
usage examples for every executable component in this repository.
