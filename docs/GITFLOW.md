# Gitflow Policy

This repository follows the same **gitflow** branching policy with mandatory pull requests as
[dotfiles-windows](https://github.com/abrioso/dotfiles-windows/blob/main/docs/GITFLOW.md), which is
the reference for all `abrioso` dotfiles repositories. Direct commits/pushes to `main` and
`develop` are blocked both locally and on GitHub.

## Branches

| Branch | Purpose | Merges into |
|--------|---------|-------------|
| `main` | Stable releases | — |
| `develop` | Next release integration | `main` (via release PR) |
| `feature/*` | New functionality | `develop` |
| `fix/*` | Non-urgent fixes | `develop` |
| `hotfix/*` | Critical fixes | `main` + `develop` |
| `release/*` | Release prep and stabilization | `main` and, when needed, `develop` |

```mermaid
flowchart LR
    develop -->|checkout -b| feature[feature/fix branch]
    feature -->|push + PR| develop
    develop -->|checkout -b| release[release/vYYYY.MM.N]
    release -->|merge-commit PR| main
    release -->|reconcile release-only commits| develop
    main -->|hotfix branch| hotfix[hotfix/*]
    hotfix -->|PR| main
    hotfix -->|PR| develop
```

## How enforcement works

- **Local git hooks** (`git-hooks/pre-commit`, `git-hooks/pre-push`): block direct commits/pushes
  to `main`/`develop`. They are the same hooks shipped by `dotfiles-windows`. To activate them for
  every repository on the machine, point `core.hooksPath` at the absolute path of the `git-hooks`
  folder in your untracked `~/.gitconfig.local` (see [Customization](CUSTOMIZATION.md)):

  ```bash
  git config --file ~/.gitconfig.local core.hooksPath "$HOME/dotfiles-linux/git-hooks"
  ```

  Bypass only in an emergency: `GITFLOW_HOOK_BYPASS=1 git commit ...`.
- **GitHub branch protection**: `main`/`develop` reject direct pushes server-side (PR required,
  `enforce_admins` on) even from another machine or collaborator. Applied from the Windows
  workstation with `powershell-scripts/Set-GitflowBranchProtection.ps1 -Repos 'abrioso/dotfiles-linux'`
  in `dotfiles-windows`. Note: GitHub's free plan only allows branch protection on public repositories.
- **Continuous integration**: `.github/workflows/validate.yml` runs `tests/validate.sh` (syntax,
  shellcheck, executable bits and whitespace checks) on every pull request and push to `develop`
  or `main`.

## Day-to-day workflow

### New feature or non-urgent fix

```bash
git checkout develop
git pull origin develop
git checkout -b feature/short-description   # or fix/short-description

# ...make changes, commit with conventional commits...
./tests/validate.sh
git add path/to/file.sh
git commit -m "feat: describe the change"

git push -u origin feature/short-description
gh pr create --base develop --title "feat: ..." --body "What/why"
```

Merge the PR on GitHub (or `gh pr merge`), then delete the branch.

### Urgent production fix (hotfix)

```bash
git checkout main
git pull origin main
git checkout -b hotfix/short-description
# fix, commit, push
gh pr create --base main --title "fix: ..."
# after merging to main, also open a PR from hotfix/* into develop to keep it in sync
```

Never merge a fix into `main` without the backport PR into `develop`; otherwise the two branches
diverge and the next release silently drops the fix.

### Release prep

```bash
git fetch --prune origin
git checkout develop
git pull --ff-only origin develop
git checkout -b release/v2026.11.0

# Apply only release stabilization changes, then push the branch.
git push -u origin release/v2026.11.0
gh pr create --base main --head release/v2026.11.0 --title "release: v2026.11.0"
```

Release versions use Calendar Versioning in the form `vYYYY.MM.N`:

- `YYYY` is the four-digit release year.
- `MM` is the zero-padded release month.
- `N` is a non-negative release number within that month, starting at `0`; when a
  date-oriented release identifier is useful, `N` may intentionally use the day of the month.
- Examples: `v2026.11.0` for the first November 2026 release, `v2026.11.1` for a second
  release in that month, or `v2026.11.23` when the final component is mapped to the day.

Before opening the production PR, run `./bootstrap.sh` on a disposable VM or container for each
supported distro family and confirm that a second `./install.sh` run is a no-op. Merge the release
PR into `main` with a **merge commit**, not squash or rebase, so the production release boundary
remains visible.

Keep the release branch until reconciliation is complete:

1. If the release branch contains stabilization commits not already in `develop`, open a second
   PR from the same `release/vYYYY.MM.N` branch into `develop` and merge it with a merge commit.
2. If there are no release-only commits, verify that the branch adds nothing to `develop`; do not
   create an empty reconciliation PR.
3. Tag the merge commit on `main` with the exact `vYYYY.MM.N` version and publish the matching
   GitHub Release.
4. Delete the release branch only after `main`, `develop`, the tag, and the GitHub Release have
   all been verified.

Do not merge `main` wholesale back into `develop` as a substitute for reconciling the release
branch. Hotfixes continue to use their own explicit backport PR into `develop`.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`,
`chore:`, `refactor:`.
