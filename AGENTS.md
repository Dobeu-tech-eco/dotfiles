# Agent Guidelines

## Repository

- Bash-based dotfiles repository; use Bash, never `sh`, for repository scripts.
- No package manager, build system, application server, formatter, or conventional
  test suite is configured.
- `docs/reference.md` is the detailed command and shell-function reference.
- Keep scripts short and defensive; existing entry points use
  `set -euo pipefail`.

## Setup

Prerequisites: Bash 4 or newer, Git, and a Unix-like system.

```bash
# Preview installation without writing files.
bash install.sh --dry-run

# Apply dotfiles. Run only when the user explicitly requests its side effects.
bash install.sh
```

Normal installation changes shell startup files, home-directory symlinks, and
Git's global configuration. There is no build command or development server.

## Validation and targeted checks

Run the repository-defined Ona task after changing shell, Git, installer, or
documentation files:

```bash
gitpod environment task start validate
gitpod environment task logs <task-reference>
```

If the Ona task is unavailable, run the authoritative script directly:

```bash
bash scripts/validate.sh
```

The validator checks all Bash syntax, entry-point executable bits, tracked
secret-file patterns, and installed dotfile symlinks. For a fast check of one
changed script:

```bash
bash -n shell/functions.sh
```

Additional required checks:

- Installation behavior changed: `bash install.sh --dry-run`
- `.devcontainer/devcontainer.json` changed:
  `gitpod environment devcontainer validate .devcontainer/devcontainer.json`
- `.ona/config.yaml` changed:
  `gitpod environment config validate .ona/config.yaml`

There are no individual automated test cases and no separate lint or format
command. The validation task is the required pre-commit check.

## Pull requests

- Run every validation relevant to the changed files before opening a PR.
- The repository declares no branch-naming or commit-message convention.
- No hosted CI workflow is checked in; `validate` is the authoritative required
  check.
- Keep secrets, machine-local files, runner state, and `.ona/review/` out of the
  diff.

## Ona workflows

Prefer checked-in workflows over reconstructing their commands:

```bash
gitpod environment task start validate
gitpod environment task start install-actions-runner
gitpod environment task logs <task-reference>
gitpod environment service start actions-runner
gitpod environment service logs actions-runner --follow
```

- Use `--format json` when machine-readable state is needed.
- After changing `.ona/config.yaml`, validate and apply it with
  `gitpod environment config update .ona/config.yaml`, then verify every affected
  task or service.
- Do not use `--dont-wait` when verifying success.
- The Actions runner is not an HTTP service and requires no exposed port.

## Key paths

- `shell/`: sourced environment, PATH, aliases, functions, and prompt.
- `git/`: shared Git configuration, local-config example, and global ignores.
- `scripts/`: repository validation and the pull-and-reinstall updater.
- `docs/`: detailed behavior and command reference.
- `.devcontainer/`: reproducible development container definition.
- `.ona/config.yaml`: Ona validation/runner tasks and Actions runner service.
- `install.sh`: mutates shell startup files and home-directory symlinks.
- `local.example`: template for the ignored `shell/local.sh` override.
- `.agent/`: checkpoint artifacts; do not edit unless specifically requested.

## Safety

- **Never** commit tokens, keys, `.env*`, `shell/local.sh`,
  `.gitconfig.local`, runner registration state, or `.ona/review/`.
- Never place `ACTIONS_RUNNER_TOKEN` in tracked files or logs.
- Do not run `install.sh` without `--dry-run`, or `scripts/update.sh`, unless the
  user explicitly requests their side effects.
- Do not edit `.agent/` checkpoint files unless specifically requested.
- Prefer built-in SCM tools for pull requests, issues, and reviews.
