# Dobeu-tech-eco Dotfiles Repository Setup Specification

## Objective

Turn the current workspace into the initial contents of the organization-owned GitHub repository `Dobeu-tech-eco/dotfiles`, create one local commit, and push it to `https://github.com/dobeu-tech-eco/dotfiles.git` using the `GH_PAT` environment variable for authentication.

## Current State

- The workspace root is already a Git repository on branch `main`.
- The repository has no commits and no configured remotes.
- Intentional workspace configuration currently consists of `.devcontainer/devcontainer.json` and `.ona/config.yaml`.
- `.ona/review/comments.json` is tool-generated review metadata and is not intended source content.
- `GH_PAT` is present in the environment. Its value must never be printed, committed, written into a remote URL, or saved in Git configuration.
- The requested `/dotfiles-setup` and `/git-init` skills are unavailable, so implementation will use the equivalent direct Git and GitHub workflow.

## Assumptions From Skipped Clarifications

- “For all of org Dobeu-tech-eco” means the repository is owned by the `Dobeu-tech-eco` GitHub organization. It does not imply automatic installation for every organization member or workstation.
- If the remote repository does not exist, create it as a private repository with default branch `main`.
- If it already exists, preserve its history and never force-push or delete remote content.
- The initial source set is the intentional workspace configuration, this specification, and a narrow `.gitignore`; runtime credentials and tool-generated metadata are excluded.
- Organization-default repository permissions remain unchanged. Team membership and organization-wide rollout are outside scope.

## Requirements

### Repository contents

1. Retain `.devcontainer/devcontainer.json` and `.ona/config.yaml` unchanged unless a secret scan finds committed credential material that must be removed.
2. Retain `spec.md` as the implementation record.
3. Add a root `.gitignore` that excludes at least:
   - `.ona/review/`
   - local GitHub Actions runner downloads, work directories, and registration/credential files if they appear beneath the repository root
   - common local secret files such as `.env` while allowing an explicitly named example file if one is later added
4. Do not add generated runner binaries, archives, logs, caches, `.git/`, or user-home dotfiles that are not already in the workspace.

### Git history

1. Treat the existing Git initialization as satisfying `/git-init`; initialize with `main` only if `.git/` is unexpectedly absent during implementation.
2. Resolve a commit identity without modifying the user's global Git configuration:
   - prefer a valid existing repository-local identity;
   - otherwise derive the authenticated GitHub login and public/noreply identity through the authenticated GitHub API and set it only in local repository config.
3. Stage all intentional, non-ignored files and review the staged path list before committing.
4. Create one commit with a concise message such as `Initialize organization dotfiles`.
5. Do not amend, rewrite, or force-update existing history.

### GitHub repository and authentication

1. Verify that `GH_PAT` is non-empty before any remote mutation, without printing its value.
2. Query `Dobeu-tech-eco/dotfiles` before attempting creation.
3. If absent, create a private repository named `dotfiles` in the `Dobeu-tech-eco` organization using authenticated GitHub API access.
4. If present and empty, reuse it. If it has commits, fetch its default branch and place the new commit on top of that history; stop without pushing if local files would overwrite conflicting remote paths without a clean integration.
5. Configure `origin` as `https://github.com/dobeu-tech-eco/dotfiles.git`. The token must not be embedded in this URL.
6. Supply `GH_PAT` ephemerally for API and HTTPS Git authentication. Disable shell tracing around authenticated operations and do not install a persistent credential helper.
7. Push `main` and set it to track `origin/main`. Never use `--force` or `--force-with-lease`.

## Constraints

- Plan mode permits only creation or revision of this specification; repository initialization, staging, committing, GitHub creation, and pushing occur only during implementation.
- Do not expose `GH_PAT` in command output, logs, process descriptions where avoidable, commit data, files, Git remotes, or final responses.
- Do not commit `.ona/review/comments.json` or credentials produced by the GitHub Actions runner.
- Do not modify organization settings, repository teams, member permissions, branch protection, Actions settings, or runner registration as part of this request.
- Do not overwrite an existing remote repository or silently merge conflicting content.
- Use the exact remote owner and repository name `Dobeu-tech-eco/dotfiles`; GitHub's lowercase HTTPS URL is acceptable as the configured remote.
- Keep implementation limited to the initial repository content, local commit, remote creation/reuse, and push.

## Architecture

The workflow has four layers:

1. **Content boundary:** `.gitignore` defines the safe tracked set. A staged-file review and secret scan enforce that boundary before commit.
2. **Local history:** the current `main` repository produces a single initial commit, or a single additive commit based on existing remote history.
3. **GitHub control plane:** an authenticated repository lookup determines whether to create the private organization repository or reuse it.
4. **Git transport:** a clean HTTPS `origin` is paired with ephemeral `GH_PAT` credentials for the push; the credential is never persisted in repository state.

## Implementation Steps

1. Reinspect `git status`, current branch, local remotes, intended files, and `GH_PAT` presence. Abort if unexpected tracked history, a conflicting remote, or a missing token changes the assumptions above.
2. Query the authenticated GitHub user for local commit identity and query `Dobeu-tech-eco/dotfiles` for existence, visibility, default branch, and current head.
3. If the repository exists with history, fetch it before creating the local commit and integrate by basing `main` on its default branch. Stop on any path collision or non-fast-forward condition requiring user judgment.
4. Add the narrow `.gitignore`, then inspect the complete candidate file list. Scan staged content and remote/config output for credential material without printing secret values.
5. Configure repository-local author identity only if necessary. Stage every intentional non-ignored file and verify that `.ona/review/`, runner artifacts, and secret files are absent from the index.
6. Create the single initialization commit and verify its file list and metadata.
7. If the GitHub repository was absent, create it as private under `Dobeu-tech-eco`. If creation reports that it already exists, re-query and follow the existing-repository path instead of retrying blindly.
8. Add or update `origin` to the clean HTTPS URL, verify that no credentials appear in `git remote -v` or local Git config, and push `main` with upstream tracking using ephemeral `GH_PAT` authentication.
9. Verify the remote branch head equals the local commit, the repository URL is correct, visibility is private when newly created, and the working tree contains no unintended staged or modified files.

## Failure Handling

- Missing or rejected `GH_PAT`: stop before repository creation or push and report only the authentication failure.
- Insufficient organization permission: leave the local commit intact and report that repository creation or push requires an organization-authorized token.
- Existing remote history with conflicting paths: fetch and stop; do not force-push, delete, or auto-resolve ambiguous content.
- Existing repository with unexpected visibility or default branch: preserve it and report the discrepancy rather than changing repository settings.
- Push rejection: fetch and inspect the new remote state; do not retry with force.

## Success Criteria

- The local repository is on `main` and has a commit containing only the intended configuration, `spec.md`, and `.gitignore`.
- `.ona/review/`, runner credentials/artifacts, `.env` files, and `GH_PAT` are absent from the commit.
- `origin` is exactly `https://github.com/dobeu-tech-eco/dotfiles.git` with no embedded credentials.
- `Dobeu-tech-eco/dotfiles` exists on GitHub; if newly created, it is private.
- Remote `main` points to the verified local commit and local `main` tracks `origin/main`.
- Existing remote history, if any, is preserved and the push is fast-forward only.
- `GH_PAT` was used ephemerally and was not disclosed or persisted.
