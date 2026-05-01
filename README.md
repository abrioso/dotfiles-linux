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
└── docs/                   # Documentation
```

## 🚀 Quick Start

```bash
git clone https://github.com/abrioso/dotfiles-linux.git ~/dotfiles-linux
cd ~/dotfiles-linux
./bootstrap.sh
```

For servers (minimal install, no GUI packages):
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

3. **Force install** (no prompts, use defaults):
   ```bash
   ./install.sh --force
   ```

## 🖼️ Screenshots

<!-- TODO: Add terminal screenshots -->

## ⚙️ Customization

- Add local overrides in `~/.zshrc.local` (sourced automatically)
- Add custom scripts to `bin/`
- See [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) for adding new stow packages

## ✅ Tested On

- Ubuntu 22.04 LTS / 24.04 LTS
- AlmaLinux 8 / 9
- Fedora 39+

## 📚 Documentation

- [Package List & Categories](docs/PACKAGES.md)
- [Customization Guide](docs/CUSTOMIZATION.md)

## 🙏 Credits

- [Oh My Zsh](https://ohmyz.sh/)
- [Starship](https://starship.rs/)
- [GNU Stow](https://www.gnu.org/software/stow/)
