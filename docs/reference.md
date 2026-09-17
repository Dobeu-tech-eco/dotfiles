# Shell and Automation Reference

This guide documents the executable behavior in the dotfiles repository. It
covers the public interactive functions, internal helpers, entry-point scripts,
aliases, environment defaults, Git aliases, and Ona automation.

## Conventions

- Function parameters are positional shell arguments such as `$1` and `$2`.
- Shell functions do not return data objects. They write data to standard output
  and report success or failure with a numeric exit status.
- Exit status `0` means success. A nonzero status indicates a negative answer,
  no result, invalid input, or a command failure as documented below.
- Paths containing spaces are supported when callers quote their arguments.
- `shell/init.sh` must be sourced, not executed, because it changes the current
  shell's environment, aliases, functions, prompt, and `PATH`.

## Loading the shell configuration

### `shell/init.sh`

Loads the shell modules in this order:

1. `env.sh`
2. `path.sh`
3. `aliases.sh`
4. `functions.sh`
5. `prompt.sh`
6. `local.sh`, when present

`local.sh` is deliberately loaded last so machine-specific values can override
shared defaults.

**Parameters:** None. The script derives its location from `BASH_SOURCE`.

**Result:** Defines environment variables, aliases, functions, and the Bash
prompt in the calling shell. It produces no output during normal loading.

**Example:**

```sh
source "$HOME/dotfiles/shell/init.sh"
```

### `_source_if_exists`

```sh
_source_if_exists FILE
```

Internal helper used by `init.sh`. It sources `FILE` into the current shell only
when it is a regular file.

| Parameter | Required | Description |
|---|---:|---|
| `FILE` (`$1`) | Yes | Module or local override to source. |

**Return status:** The sourced file's status when it exists; nonzero when the
file does not exist. Missing optional modules are intentionally ignored by the
top-level loader.

## Interactive shell functions

These functions become available after sourcing `shell/init.sh` or
`shell/functions.sh`.

### `mkcd`

```sh
mkcd DIRECTORY
```

Creates a directory, including missing parents, then changes the current shell's
working directory to it.

| Parameter | Required | Description |
|---|---:|---|
| `DIRECTORY` (`$1`) | Yes | Directory to create and enter. Relative and absolute paths are accepted. |

**Return status:** `0` when both `mkdir` and `cd` succeed; `1` when changing
directory fails. A failed `mkdir` also results in a nonzero status.

**Side effects:** Creates directories and changes the current working directory.

**Examples:**

```sh
mkcd projects/new-service
mkcd "$HOME/Projects/Client Work"
```

### `up`

```sh
up [COUNT]
```

Moves up `COUNT` parent directories. With no argument, it moves up one level.

| Parameter | Required | Default | Description |
|---|---:|---:|---|
| `COUNT` (`$1`) | No | `1` | Nonnegative integer number of parent levels. |

**Return status:** `0` when `cd` succeeds; `1` when the target cannot be entered.

**Side effects:** Changes the current working directory.

**Examples:**

```sh
up       # equivalent to: cd ..
up 3     # equivalent to: cd ../../..
up 0     # remains in the current directory
```

### `extract`

```sh
extract ARCHIVE
```

Extracts an archive in the current directory by choosing a command from the file
extension.

| Parameter | Required | Description |
|---|---:|---|
| `ARCHIVE` (`$1`) | Yes | Existing archive file to extract. |

Supported extensions and tools:

| Extension | Command |
|---|---|
| `.tar.bz2` | `tar xjf` |
| `.tar.gz` | `tar xzf` |
| `.tar.xz` | `tar xJf` |
| `.tar` | `tar xf` |
| `.bz2` | `bunzip2` |
| `.gz` | `gunzip` |
| `.zip` | `unzip` |
| `.Z` | `uncompress` |
| `.7z` | `7z x` |

**Return status:** `0` when extraction succeeds; `1` for a missing argument, a
non-file path, or an unsupported extension. For a recognized archive, the
underlying extraction command's status is returned.

**Output:** Error and usage messages are written to standard error. Extraction
tools may write progress or extracted filenames to standard output.

**Side effects:** Creates extracted files. Single-file compression formats such
as `.gz` and `.bz2` may remove the compressed input according to the underlying
tool's default behavior.

**Examples:**

```sh
extract release.tar.gz
extract "$HOME/Downloads/source bundle.zip"
```

The relevant extraction utility must already be installed.

### `confirm`

```sh
confirm [PROMPT]
```

Displays a yes/no prompt and reads one line from standard input. Only `y` or
`yes`, in any letter case, is accepted. The default is no.

| Parameter | Required | Default | Description |
|---|---:|---|---|
| `PROMPT` (`$1`) | No | `Are you sure?` | Text displayed before `[y/N]`. |

**Return status:** `0` for `y` or `yes`; `1` for every other response, including
an empty response.

**Example:**

```sh
if confirm "Delete generated files?"; then
  rm -r build/
fi
```

### `path_prepend`

```sh
path_prepend DIRECTORY
```

Prepends an existing directory to `PATH` when the exact directory is not already
present as a path component.

| Parameter | Required | Description |
|---|---:|---|
| `DIRECTORY` (`$1`) | Yes | Directory to conditionally add to `PATH`. |

**Return status:** `0` when the directory is added; nonzero when it does not
exist or is already present.

**Side effects:** Exports the updated `PATH` in the current shell.

**Examples:**

```sh
path_prepend "$HOME/.cargo/bin"
path_prepend "/opt/custom tools/bin"
```

### `find_in`

```sh
find_in PATTERN [DIRECTORY]
```

Recursively searches shell source files for a basic regular expression. Only
files ending in `.sh`, `.bash`, or `.zsh` are searched.

| Parameter | Required | Default | Description |
|---|---:|---|---|
| `PATTERN` (`$1`) | Yes | — | Basic regular expression passed to `grep`. |
| `DIRECTORY` (`$2`) | No | `.` | Search root. |

**Return status:** The status from `grep`: `0` when a match is found, `1` when no
match is found, and `2` for an error. Omitting `PATTERN` stops immediately with a
usage message because shell parameter validation is used.

**Output:** Matching lines, with filenames and terminal colors where supported.

**Examples:**

```sh
find_in 'path_prepend'
find_in 'TODO\|FIXME' "$HOME/dotfiles/shell"
```

### `epoch`

```sh
epoch
```

Prints the current Unix timestamp in whole seconds.

**Parameters:** None.

**Return status:** The status returned by `date`.

**Output:** One integer followed by a newline.

**Example:**

```sh
started_at=$(epoch)
```

## PATH internals

### `_prepend_path`

```sh
_prepend_path DIRECTORY
```

Internal startup helper in `shell/path.sh`. It prepends an existing directory
only if that exact path component is absent. Startup tries, in order,
`$HOME/.local/bin`, `$HOME/bin`, `/opt/homebrew/bin`, and `/usr/local/bin`.

| Parameter | Required | Description |
|---|---:|---|
| `DIRECTORY` (`$1`) | Yes | Candidate binary directory. |

**Return status:** `0`. A missing or duplicate directory is a successful no-op.

**Side effects:** May export a new `PATH`. The function is deleted with
`unset -f` after startup and is not part of the interactive API. Use
`path_prepend` for later additions.

## Prompt internals

### `_git_branch`

```sh
_git_branch
```

Internal Bash prompt helper. It prints the current symbolic Git branch wrapped
in parentheses.

**Parameters:** None.

**Return status:** `0` and branch text inside a branch; nonzero with no output
outside a Git worktree or when `HEAD` is detached.

**Output example:**

```text
 (main)
```

The function is interpolated by `PS1` on every prompt. `prompt.sh` does nothing
under zsh; zsh prompt customization belongs in `shell/local.sh`.

## Installer API

### `install.sh`

```sh
bash install.sh [--dry-run]
```

Idempotently installs the repository's shell and Git configuration.

| Option | Description |
|---|---|
| `--dry-run` | Reports planned changes without writing files or Git configuration. |

Unknown options exit immediately with status `1`.

**Return status:** `0` after successful setup; nonzero for invalid arguments,
missing Git, or an unhandled filesystem failure.

**Side effects in normal mode:**

- Adds a source line to existing `~/.bashrc` and `~/.zshrc` files.
- Symlinks the shared Git config to `~/.gitconfig`.
- Symlinks the global ignore file to `~/.gitignore_global`.
- Sets Git's global `core.excludesFile` when possible.
- Creates the ignored `shell/local.sh` from `local.example` when absent.
- Backs up a non-symlink destination as `DESTINATION.bak` before linking.

**Examples:**

```sh
bash install.sh --dry-run
bash install.sh
```

### Installer output helpers: `info`, `ok`, `warn`, `error`

```sh
info MESSAGE...
ok MESSAGE...
warn MESSAGE...
error MESSAGE...
```

Formats all arguments as one colored status line. `info`, `ok`, and `warn`
write to standard output; `error` writes to standard error.

**Parameters:** Zero or more words forming the message.

**Return status:** Normally `0`, inherited from `printf`.

### `link`

```sh
link SOURCE DESTINATION
```

Creates or repairs an installation symlink.

| Parameter | Required | Description |
|---|---:|---|
| `SOURCE` (`$1`) | Yes | Symlink target, normally an absolute path inside the repository. |
| `DESTINATION` (`$2`) | Yes | Path at which the symlink is installed. |

**Return status:** `0` after a successful link, when the exact link already
exists, or after a dry-run report. Filesystem failures return nonzero and stop
the installer because `set -e` is enabled.

**Side effects:** In normal mode, an existing non-symlink destination is moved
to `DESTINATION.bak`, then a symlink is created or replaced. An unrelated
existing symlink is replaced without a backup.

### `setup_shell_rc`

```sh
setup_shell_rc RC_FILE
```

Adds the repository's `shell/init.sh` source line to an existing shell startup
file, unless the exact line is already present.

| Parameter | Required | Description |
|---|---:|---|
| `RC_FILE` (`$1`) | Yes | Shell startup file, such as `~/.bashrc` or `~/.zshrc`. |

**Return status:** `0` for an absent file, an existing entry, a dry run, or a
successful append. A write failure returns nonzero and stops the installer.

**Side effects:** Appends a comment and `source` line in normal mode.

## Updater API

### `scripts/update.sh`

```sh
bash scripts/update.sh
```

Fetches `origin`, determines the current branch, fast-forward pulls its matching
remote branch when one exists, then runs `install.sh` to reapply configuration.

**Parameters:** None.

**Return status:** `0` after a successful update and reinstall. Returns `1` when
fetch fails; other Git, installer, or filesystem failures propagate as nonzero
statuses because `set -e` is enabled.

**Safety behavior:** Pulling uses `--ff-only`, so the updater does not create a
merge commit or rewrite local history. A detached `HEAD` falls back to the name
`main` for the remote-branch lookup.

**Example:**

```sh
bash "$HOME/dotfiles/scripts/update.sh"
```

The updater defines private `info`, `ok`, and `error` formatting helpers with the
same parameter and output conventions as the installer helpers.

## Validator API

### `scripts/validate.sh`

```sh
bash scripts/validate.sh
```

Runs four repository checks:

1. Parses every `.sh` and `.bash` file with `bash -n`, excluding `.git` and
   `.agent`.
2. Confirms `install.sh`, `scripts/validate.sh`, and `scripts/update.sh` are
   executable when present.
3. Searches tracked paths for known secret-file patterns.
4. Reports whether the installed `~/.gitconfig` and `~/.gitignore_global`
   symlinks are valid, broken, or not installed.

**Parameters:** None.

**Return status:** `0` when all checks pass; `1` when one or more checks fail.

**Output:** A colored line per check followed by `All checks passed.` or
`Some checks failed.`

**Example:**

```sh
if bash scripts/validate.sh; then
  echo "Ready to commit"
fi
```

### Validator output helpers: `pass`, `fail`, `info`

```sh
pass MESSAGE...
fail MESSAGE...
info MESSAGE...
```

| Function | Output | State change | Return status |
|---|---|---|---:|
| `pass` | Green message on standard output | None | Normally `0` |
| `fail` | Red message on standard error | Sets aggregate `status=1` | Normally `0` |
| `info` | Blue message on standard output | None | Normally `0` |

`fail` records a failure without immediately stopping validation, allowing all
checks to report in one run.

## Shell aliases

Aliases are defined by `shell/aliases.sh` after `env.sh` selects an editor.

### Navigation and listing

| Alias | Expansion | Purpose |
|---|---|---|
| `..`, `...`, `....` | `cd ..`, `cd ../..`, `cd ../../..` | Move up one to three levels. |
| `ls` | GNU `ls --color=auto` or BSD `ls -G` | Colorized listing. |
| `ll` | Long, human-readable listing | Show normal files. |
| `la` | Long, human-readable listing | Include hidden files. |
| `l` | `ll` | Short form of the long listing. |

The installer detects GNU versus BSD `ls` before defining listing aliases.

### File and search commands

| Alias | Expansion | Purpose |
|---|---|---|
| `cp` | `cp -i` | Prompt before overwrite. |
| `mv` | `mv -i` | Prompt before overwrite. |
| `rm` | `rm -i` | Prompt before removal. |
| `mkdir` | `mkdir -p` | Create parents and accept existing directories. |
| `grep`, `fgrep`, `egrep` | Command plus `--color=auto` | Highlight matches. |

### Git aliases

| Alias | Expansion |
|---|---|
| `g` | `git` |
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gco` | `git checkout` |
| `gd` | `git diff` |
| `gl` | `git log --oneline --graph --decorate` |
| `gp` | `git push` |
| `gpl` | `git pull` |

Example:

```sh
gs
ga README.md
gc -m "Document shell API"
```

### Utility aliases

| Alias | Behavior |
|---|---|
| `e` | Opens arguments with `$EDITOR`. |
| `reload` | Sources `~/.bashrc`, falling back to `~/.zshrc`. |
| `path` | Prints one `PATH` component per line. |
| `now` | Prints local time as `YYYY-MM-DD HH:MM:SS`. |
| `week` | Prints the ISO week number. |
| `dotfiles` | Attempts to enter the configured dotfiles directory. |

Examples:

```sh
e shell/functions.sh
now
path
reload
```

## Environment variables

`shell/env.sh` preserves caller-provided values for most general environment
variables and supplies defaults where absent.

| Variable | Default or selection | Description |
|---|---|---|
| `LANG` | `en_US.UTF-8` | Process locale. |
| `LC_ALL` | `en_US.UTF-8` | Locale override for all categories. |
| `EDITOR` | First of `nvim`, `vim`, `nano` | Preferred interactive editor. |
| `VISUAL` | Same selection as `EDITOR` | Preferred full-screen editor. |
| `PAGER` | `less` | Default pager. |
| `LESS` | `-R -F -X` | Preserve colors, quit for short output, and retain screen contents. |
| `HISTSIZE` | `10000` | In-memory Bash history entries. |
| `HISTFILESIZE` | `20000` | On-disk Bash history entries. |
| `HISTCONTROL` | `ignoreboth:erasedups` | Ignore leading-space/duplicate commands and erase older duplicates. |
| `XDG_CONFIG_HOME` | `$HOME/.config` | User configuration root. |
| `XDG_DATA_HOME` | `$HOME/.local/share` | User data root. |
| `XDG_CACHE_HOME` | `$HOME/.cache` | User cache root. |

Override values in the ignored `shell/local.sh`:

```sh
export EDITOR="code --wait"
export LANG="en_GB.UTF-8"
path_prepend "$HOME/custom/bin"
```

## Git command aliases

The following commands come from the `[alias]` section in `git/.gitconfig` after
installation:

| Command | Description | Output or effect |
|---|---|---|
| `git st` | Short branch-aware status. | Runs `status -sb`. |
| `git lg` | Graph all refs. | Compact decorated log. |
| `git last` | Inspect the latest commit. | Latest commit plus file statistics. |
| `git undo` | Remove the latest commit. | Soft reset; changes remain staged. |
| `git ba` | List local and remote branches. | Runs `branch -a`. |
| `git amend` | Amend without editing the message. | Replaces the latest commit. |
| `git aliases` | List configured aliases. | Matching Git configuration entries. |
| `git su` | Stash tracked and untracked files. | Creates a stash entry. |
| `git cleanup` | Delete merged local branches except protected names. | Removes branches already merged into the current branch. |

Examples:

```sh
git st
git lg
git su
git cleanup
```

`git undo`, `git amend`, and `git cleanup` change repository history or local
branches; inspect the current state before using them.

## Ona automation

The workflows in `.ona/config.yaml` manage a self-hosted GitHub Actions runner.

### Task: `install-actions-runner`

Downloads runner version `2.337.0` into
`${XDG_DATA_HOME:-$HOME/.local/share}/actions-runner`, verifies the pinned SHA-256
checksum, and extracts it. It is idempotent: an existing executable `run.sh`
skips the download.

**Inputs:** Uses `HOME` and optionally `XDG_DATA_HOME`. It has no command-line
parameters.

**Return status:** `0` when the runner is already installed or installation
succeeds; nonzero for download, checksum, or extraction failure.

**Triggers:** Manual, post-Dev-Container-start, and prebuild.

**Example:**

```sh
gitpod environment task start install-actions-runner
```

### Service: `actions-runner`

Waits up to five minutes for the runner installation, performs unattended
registration when `.runner` is absent, then runs the listener in the foreground.
The readiness probe succeeds when `Runner.Listener` is present.

**Environment inputs:**

| Variable | Required | Default | Description |
|---|---:|---|---|
| `ACTIONS_RUNNER_TOKEN` | For first registration only | None | Short-lived GitHub runner registration token. |
| `ACTIONS_RUNNER_URL` | No | `https://github.com/Dobeu-tech-eco` | GitHub organization or repository registration URL. |
| `ACTIONS_RUNNER_NAME` | No | `ona-$(hostname)` | Runner display name. |
| `XDG_DATA_HOME` | No | `$HOME/.local/share` | Parent of the runner installation directory. |

**Return behavior:** The service remains running while the listener runs. It
stops with a nonzero status when installation never appears, required initial
registration input is absent, registration fails, or the listener exits with an
error.

**Triggers:** Manual and post-environment-start.

**Example:**

```sh
export ACTIONS_RUNNER_TOKEN="<short-lived-registration-token>"
gitpod environment service start actions-runner
gitpod environment service list
```

Do not place the token in `.ona/config.yaml`, shell history, or a tracked local
override.

## End-to-end examples

### Install on a new machine

```sh
git clone https://github.com/Dobeu-tech-eco/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
bash install.sh --dry-run
bash install.sh
cp git/.gitconfig.local.example "$HOME/.gitconfig.local"
source "$HOME/.bashrc"
```

### Add a local-only tool directory

```sh
printf '%s\n' 'path_prepend "$HOME/tools/bin"' >> shell/local.sh
reload
```

### Validate and update

```sh
cd "$HOME/dotfiles"
bash scripts/validate.sh
bash scripts/update.sh
```
