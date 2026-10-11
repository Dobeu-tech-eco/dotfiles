# Agent Guidelines

## Project

- Bash-based dotfiles repository for Linux and macOS.
- Requires Bash 4+ and Git. Use Bash, never `sh`, for repository scripts.
- No dependency manager, build system, application server, or monorepo packages.
- See `docs/reference.md` for detailed command behavior.

## Setup

| Purpose | Command | Notes |
|---|---|---|
| Preview installation | `bash install.sh --dry-run` | Safe; makes no changes. |
| Install dotfiles | `bash install.sh` | Mutates shell startup files and home-directory symlinks; run only when explicitly requested. |
| Reload Bash config | `source ~/.bashrc` | Use after installation. |
| Install the Actions runner | `gitpod environment task start install-actions-runner` | Ona task; installs the pinned runner version. |

There is no dependency-install, build, or dev-server command for this
repository.

## Tests and validation

- Full repository check: `gitpod environment task start validate`
- Task output: `gitpod environment task logs <task-reference>`
- Fallback when the Ona task is unavailable: `bash scripts/validate.sh`
- Focused syntax check example: `bash -n shell/functions.sh`
- Focused installer behavior check: `bash install.sh --dry-run`

There is no conventional test suite or individual-test selector. The
authoritative validation checks all shell syntax, executable entry points,
tracked secret-file patterns, and installed dotfile symlinks.

Run additional checks when the affected files require them:

| Change | Required check |
|---|---|
| Shell, Git, installer, or documentation | `gitpod environment task start validate` |
| Installation behavior | `bash install.sh --dry-run` |
| `.devcontainer/devcontainer.json` | `gitpod environment devcontainer validate .devcontainer/devcontainer.json` |
| `.ona/config.yaml` | `gitpod environment config validate .ona/config.yaml` |

After changing `.ona/config.yaml`, apply and verify it with
`gitpod environment config update .ona/config.yaml`. Do not use `--dont-wait`
when verifying success.

## Lint and format

- No dedicated linter or formatter is configured.
- Run the full `validate` task before committing.
- Keep scripts defensive with `set -euo pipefail`.
- Preserve executable permissions on `install.sh`, `scripts/validate.sh`, and
  `scripts/update.sh`.

## Ona workflows

- List tasks: `gitpod environment task list`
- Start validation: `gitpod environment task start validate`
- Install the Actions runner: `gitpod environment task start install-actions-runner`
- Start the runner: `gitpod environment service start actions-runner`
- Follow runner logs: `gitpod environment service logs actions-runner --follow`
- Use `--format json` when machine-readable state is needed.

The Actions runner is not an HTTP service and requires no exposed port.

## Commits and pull requests

- Branch naming: no repository-specific convention is defined.
- Commit format: no format is enforced; use a concise, imperative summary.
- Before opening a PR, run the checks listed under **Tests and validation** for
  every changed area.
- No GitHub Actions workflow or required CI check is defined in this repository;
  the Ona `validate` task is the required pre-commit check.
- Prefer built-in SCM tools for pull requests, issues, and reviews.

## Key paths

| Path | Purpose |
|---|---|
| `shell/` | Sourced environment, PATH, aliases, functions, and prompt. |
| `git/` | Shared Git configuration, local-config template, and global ignore rules. |
| `scripts/validate.sh` | Authoritative repository validation. |
| `scripts/update.sh` | Fast-forward pull followed by installation; has side effects. |
| `install.sh` | Idempotent dotfile installer and symlink manager. |
| `docs/reference.md` | Detailed shell and automation command reference. |
| `.devcontainer/` | Reproducible development-container definition. |
| `.ona/config.yaml` | Ona tasks and the Actions runner service. |
| `.agent/` | Agent checkpoint artifacts; do not edit unless requested. |

## Safety

- **Never** commit tokens, keys, `.env*`, `shell/local.sh`, `.gitconfig.local`,
  runner registration state, or `.ona/review/`.
- Never place `ACTIONS_RUNNER_TOKEN` in tracked files or logs.
- Do not run `install.sh` without `--dry-run`, or `scripts/update.sh`, unless the
  user explicitly requests their side effects.
- Do not edit `.agent/` checkpoint files unless specifically requested.
