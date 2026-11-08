# ⚙️ Customization Guide

## Adding a New Stow Package

1. Create a directory under `config/` with the package name:
   ```bash
   mkdir -p config/myapp/.config/myapp
   ```

2. Place files using the same path structure as they would appear in `$HOME`:
   ```
   config/myapp/.config/myapp/config.yml  →  ~/.config/myapp/config.yml
   ```

3. Run `./install.sh` to create symlinks.

## Local Overrides

- **Zsh**: Create `~/.zshrc.local` for machine-specific aliases/exports
- **Git**: `install.sh` creates `~/.gitconfig.local` with your identity on first run; the tracked
  `config/git/.gitconfig` includes it. Put every machine-specific value there (identity,
  `credential.helper`, `core.hooksPath` for the gitflow hooks). Use `git config --local` for
  per-repo settings.

```ini
# ~/.gitconfig.local
[user]
    name = Your Name
    email = you@example.com
[core]
    hooksPath = /home/you/dotfiles-linux/git-hooks
```

## Adding Custom Scripts

Place executable scripts in `bin/`. They'll be on your PATH via the `.zshrc` config.

```bash
cp my-script.sh bin/
chmod +x bin/my-script.sh
```

## Platform-Specific Configs

For configs that differ between machines, use conditional logic:

```bash
# In .zshrc.local
if [ "$(hostname)" = "webserver01" ]; then
    export EDITOR=nano
fi
```

## Adding Packages

- Edit `packages/common.txt` for cross-distro packages
- Edit `packages/ubuntu.txt` or `packages/rhel.txt` for distro-specific ones
- One package per line, comments start with `#`
