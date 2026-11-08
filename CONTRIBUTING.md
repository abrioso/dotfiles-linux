# Contributing

## Branching Strategy

This project uses **gitflow**. See [docs/GITFLOW.md](docs/GITFLOW.md) for the full policy, enforcement details, and workflow examples.

## How to Contribute

1. **Fork** or create a feature branch from `develop`:
   ```bash
   git checkout develop && git pull
   git checkout -b feature/my-change
   ```

2. **Make your changes** following the code standards below.

3. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` — new feature
   - `fix:` — bug fix
   - `docs:` — documentation only
   - `chore:` — maintenance, deps
   - `refactor:` — code restructure without behavior change

4. **Push and open a PR** targeting `develop`:
   ```bash
   git push -u origin feature/my-change
   gh pr create --base develop
   ```

5. **Wait for review** before merging.

## Code Standards

### Shell Scripts
- Use `#!/bin/bash` with `set -euo pipefail`
- Must pass `shellcheck` cleanly
- Must be idempotent (safe to re-run)
- Use functions for logical grouping
- Add `--help` flag for user-facing scripts
- `git-hooks/*` are the exception: POSIX `#!/bin/sh` without strict mode, byte-identical to the
  copies in `dotfiles-windows` and the sibling repository. Edit them in all repositories together

Run `./tests/validate.sh --base-ref origin/develop` before committing. This is the same
validation entry point used in CI (`.github/workflows/validate.yml`).

### Documentation
- Update `README.md` when adding features
- Document new packages in `docs/PACKAGES.md` and add them to the matching `packages/*.txt` list
- Keep lists sorted alphabetically

### Dotfiles (config/)
- Each application gets its own stow package directory
- Follow XDG Base Directory spec where possible
- Add comments explaining non-obvious settings
- Tracked files hold shared defaults only; machine-specific values go to untracked
  `~/.gitconfig.local` and `~/.zshrc.local`

## Release Process

1. Create `release/vYYYY.MM.N` from an up-to-date `origin/develop`.
2. Apply only release stabilization changes and open a PR into `main`.
3. Run `./bootstrap.sh` on a disposable VM or container for each supported distro family and confirm
   a second `./install.sh` run is a no-op.
4. Merge the production PR with a merge commit.
5. If the release branch has release-only commits, merge the same branch into `develop` through
   a second PR; do not merge `main` wholesale back into `develop`.
6. Tag the verified `main` merge commit and publish the matching GitHub Release.
7. Delete the release branch only after production and integration reconciliation are complete.

Versions use Calendar Versioning: `vYYYY.MM.N`, for example `v2026.11.0`. `N` normally starts at
`0` and increments for additional releases in the same month; it may instead be mapped explicitly
to the day of the month for a date-oriented release identifier.
