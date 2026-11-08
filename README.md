# 🐧 dotfiles-linux

![Shell](https://img.shields.io/badge/shell-zsh-green)
![OS](https://img.shields.io/badge/OS-Ubuntu%20|%20AlmaLinux-blue)
![License](https://img.shields.io/badge/license-MIT-yellow)

Personal Linux dotfiles for sysadmin/network engineering workstations and servers. Distro-agnostic with support for Ubuntu/Debian and RHEL/AlmaLinux/Fedora.

## 📦 What's Included

```
dotfiles-linux/
├── bootstrap.sh            # One-command setup
├── install.sh              # Symlink manager (stow + fallback)
├── config/                 # Dotfile packages
│   ├── zsh/.zshrc
│   ├── vim/.vimrc
│   ├── git/.gitconfig
│   ├── tmux/.tmux.conf
│   └── starship/.config/starship.toml
├── packages/               # Package lists by distro
├── scripts/                # Helper scripts
├── bin/                    # Custom scripts (added to PATH)
├── git-hooks/              # Gitflow pre-commit/pre-push hooks (shared with dotfiles-windows)
├── tests/validate.sh       # Local + CI validation (bash -n, shellcheck, whitespace)
└── docs/                   # Documentation
```

## 🚀 Quick Start

```bash
git clone https://github.com/abrioso/dotfiles-linux.git ~/dotfiles-linux
cd ~/dotfiles-linux
./bootstrap.sh
```

For servers (minimal install: only `packages/common.txt`, no distro-specific extras):
```bash
./bootstrap.sh --minimal
```

## 🔧 Manual Steps

1. **Install dotfiles only** (no packages):
   ```bash
   ./install.sh
   ```

2. **Dry run** (see what would change):
   ```bash
   ./install.sh --dry-run
   ```

3. **Force install** (never prompts; the Git identity is taken from `GIT_USER_NAME` /
   `GIT_USER_EMAIL` or from the existing git config, otherwise left for you to set):
   ```bash
   GIT_USER_NAME="Your Name" GIT_USER_EMAIL="you@example.com" ./install.sh --force
   ```

## 🖼️ Screenshots

<!-- TODO: Add terminal screenshots -->

## ⚙️ Customization

- Add local overrides in `~/.zshrc.local` (sourced automatically)
- Git identity and other machine-specific Git settings live in `~/.gitconfig.local`, created by
  `install.sh` on first run (prompting, or from `GIT_USER_NAME`/`GIT_USER_EMAIL`, or from the
  identity git already resolves) and included by the tracked `.gitconfig`; the tracked file never
  changes on a machine. A pre-existing `~/.gitconfig` also has its `core.hooksPath` and
  `credential.helper` carried over; the rest stays in `~/.dotfiles-backup/<timestamp>/.gitconfig`
- Add custom scripts to `bin/`
- See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for adding new stow packages

## ✅ Validation

Pull requests and pushes to `develop` or `main` run `bash -n`, shellcheck, executable-bit and
whitespace checks through GitHub Actions. Run the same checks locally:

```bash
./tests/validate.sh
./tests/validate.sh --base-ref origin/develop   # also check the committed range
```

Releases follow the `vYYYY.MM.N` Calendar Versioning and Git Flow process documented in
[Gitflow Policy](docs/GITFLOW.md).

## ✅ Tested On

- Ubuntu 22.04 LTS / 24.04 LTS
- AlmaLinux 8 / 9
- Fedora 39+

## 📚 Documentation

- [Package List & Categories](docs/PACKAGES.md)
- [Customization Guide](docs/CUSTOMIZATION.md)
- [Gitflow Policy](docs/GITFLOW.md)
- [Contributing](CONTRIBUTING.md) and [AI agent instructions](AGENTS.md)

## 🔗 Related repositories

The same owner keeps one dotfiles repository per platform. All of them follow the same gitflow,
Conventional Commits and `vYYYY.MM.N` release policy; `dotfiles-windows` is the reference.

- [dotfiles-windows](https://github.com/abrioso/dotfiles-windows) — Windows 11 (PowerShell, winget, WSL)
- [dotfiles-termux](https://github.com/abrioso/dotfiles-termux) — Android Termux (zsh, vim, same shell aliases)

## 🙏 Credits

- [Oh My Zsh](https://ohmyz.sh/)
- [Starship](https://starship.rs/)
- [GNU Stow](https://www.gnu.org/software/stow/)
