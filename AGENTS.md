# Agent Guidelines

## Project

- Bash-based dotfiles repository; use Bash, never `sh`, for repository scripts.
- No package manager, build step, development server, monorepo packages, or
  conventional test suite is configured.
- See `docs/reference.md` for detailed command behavior.

## Setup

- Prerequisites: Bash 4+ or zsh, Git, and a Unix-like system.
- Preview installation without writing files: `bash install.sh --dry-run`.
- Apply the dotfiles: `bash install.sh`.
- `install.sh` changes shell startup files and home-directory symlinks. Do not
  run it without `--dry-run` unless the user explicitly requests those side
  effects.
- There is no build or development-server command.

## Tests and pre-commit checks

- Preferred full validation: `gitpod environment task start validate`.
- Local fallback when the Ona task is unavailable: `bash scripts/validate.sh`.
- Focused shell syntax check: `bash -n shell/functions.sh` (replace the path
  with the changed `*.sh` or `*.bash` file).
- `scripts/validate.sh` checks Bash syntax, executable entry points, tracked
  secret-file patterns, and installed dotfile symlinks. It has no selector for
  running one check independently.
- No separate lint or format command is configured; the full validation is the
  required pre-commit check for shell, Git, installer, and documentation files.
- After changing installation behavior, also run `bash install.sh --dry-run`.
- After changing the development environment, run:
  - `gitpod environment devcontainer validate .devcontainer/devcontainer.json`
  - `gitpod environment config validate .ona/config.yaml`

## Pull requests

- The repository defines no branch naming convention or commit-message format.
- No CI workflow or required status check is defined in tracked source. Treat a
  successful `validate` task as the required pre-PR check.
- Include the installation dry run or environment validations when the changed
  files require them, as described above.
- Never include tokens, keys, local overrides, runner registration state, or
  `.ona/review/` in a pull request.

## Ona workflows

- Validate the repository: `gitpod environment task start validate`.
- Install the Actions runner: `gitpod environment task start install-actions-runner`.
- Inspect task output: `gitpod environment task logs <task-reference>`.
- Start the runner: `gitpod environment service start actions-runner`.
- Follow runner output: `gitpod environment service logs actions-runner --follow`.
- Add `--format json` when machine-readable state is needed.
- After changing `.ona/config.yaml`, validate and apply it with
  `gitpod environment config update .ona/config.yaml`, then verify every affected
  task or service. Do not use `--dont-wait` when verifying success.
- The Actions runner is not an HTTP service and requires no exposed port.

## Key directories and files

- `shell/`: sourced environment, PATH, aliases, functions, and prompt modules.
- `git/`: shared Git configuration, local-identity example, and global ignores.
- `scripts/`: repository validation and the side-effecting update workflow.
- `docs/`: detailed shell and automation reference documentation.
- `.devcontainer/`: reproducible development-container definition.
- `.ona/`: Ona tasks and the Actions runner service.
- `.agent/`: generated agent checkpoint state; do not edit unless requested.
- `install.sh`: idempotent bootstrap/apply script for shell startup and symlinks.
- `local.example`: template for the ignored `shell/local.sh` override.
- `spec.md`: initial repository setup specification and implementation record.

## Safety

- **NEVER** commit tokens, keys, `.env*`, `shell/local.sh`, `.gitconfig.local`,
  runner registration state, or `.ona/review/`.
- Never place `ACTIONS_RUNNER_TOKEN` in tracked files or logs.
- Do not run `scripts/update.sh` unless the user explicitly requests its fetch,
  fast-forward pull, and installation side effects.
- Prefer built-in SCM tools for pull requests, issues, and reviews.
