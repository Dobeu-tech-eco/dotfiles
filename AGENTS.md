# Agent Guidelines

## Project

This is a Bash-based dotfiles repository. It has no build system, dependency
manager, application server, or conventional test suite. Use Bash, never `sh`,
for repository scripts. See `docs/reference.md` for detailed command behavior.

## Required validation

- After changing shell, Git, installer, or documentation files, run the Ona
  `validate` task. Fall back to `bash scripts/validate.sh` only when the task is
  unavailable.
- When changing installation behavior, also run `bash install.sh --dry-run`.
- Validate environment changes with:
  - `gitpod environment devcontainer validate .devcontainer/devcontainer.json`
  - `gitpod environment config validate .ona/config.yaml`

## Ona workflows

Prefer repository-defined workflows over reconstructing their commands:

- `gitpod environment task start validate`
- `gitpod environment task start install-actions-runner`
- `gitpod environment task logs <task-reference>`
- `gitpod environment service start actions-runner`
- `gitpod environment service logs actions-runner --follow`
- Use `--format json` when machine-readable state is needed.

After changing `.ona/config.yaml`, validate and apply it with
`gitpod environment config update .ona/config.yaml`, then verify every affected
task or service. Do not use `--dont-wait` when verifying success. The Actions
runner is not an HTTP service and requires no exposed port.

## Structure

- `shell/` contains sourced environment, PATH, aliases, functions, and prompt.
- `git/` contains shared Git configuration and ignore rules.
- `install.sh` mutates shell startup files and home-directory symlinks.
- `scripts/validate.sh` is the authoritative repository validation.
- `scripts/update.sh` fast-forward pulls and then runs the installer.
- `.ona/config.yaml` defines Ona tasks and the Actions runner service.

## Safety

- **NEVER** commit tokens, keys, `.env*`, `shell/local.sh`, `.gitconfig.local`,
  runner registration state, or `.ona/review/`.
- Never place `ACTIONS_RUNNER_TOKEN` in tracked files or logs.
- Do not run `install.sh` without `--dry-run`, or `scripts/update.sh`, unless the
  user explicitly requests their side effects.
- Do not edit `.agent/` checkpoint files unless specifically requested.
- Prefer built-in SCM tools for pull requests, issues, and reviews.
