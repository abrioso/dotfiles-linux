#!/bin/bash
# install.sh — Symlink dotfiles using stow or manual fallback
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
DRY_RUN=false
FORCE=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
        --help|-h)
            echo "Usage: ./install.sh [--dry-run] [--force]"
            echo "  --dry-run  Show what would be done without making changes"
            echo "  --force    Never prompt; Git identity comes from GIT_USER_NAME/GIT_USER_EMAIL"
            echo "             or the existing git config, otherwise it is left unset"
            exit 0
            ;;
    esac
done

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\033[1;32m[ OK ]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }

backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        local rel_path="${file#"$HOME"/}"
        local backup_path="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_path")"
        if [ "$DRY_RUN" = true ]; then
            info "[DRY-RUN] Would backup: $file -> $backup_path"
        else
            mv "$file" "$backup_path"
            info "Backed up: $file -> $backup_path"
        fi
    fi
}

# Create or complete ~/.gitconfig.local (untracked) with the Git identity.
# Sources, in order: values already in the local file, GIT_USER_NAME /
# GIT_USER_EMAIL, the identity Git currently resolves (for example a
# pre-existing ~/.gitconfig that is about to be replaced), then an interactive
# prompt. With --force nothing is asked and a missing identity is only
# reported; no placeholder identity is ever written.
setup_git_config() {
    local local_config="$HOME/.gitconfig.local"
    if ! command -v git >/dev/null 2>&1; then
        warn "git not found; skipping Git identity setup."
        return 0
    fi
    local git_name git_email
    git_name=$(git config --file "$local_config" --get user.name 2>/dev/null || true)
    git_email=$(git config --file "$local_config" --get user.email 2>/dev/null || true)
    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        info "Git identity already configured in $local_config"
        return 0
    fi
    if [ -z "$git_name" ]; then
        git_name="${GIT_USER_NAME:-$(git config --global --get user.name 2>/dev/null || true)}"
    fi
    if [ -z "$git_email" ]; then
        git_email="${GIT_USER_EMAIL:-$(git config --global --get user.email 2>/dev/null || true)}"
    fi
    if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
        if [ -z "$git_name" ]; then
            read -rp "Git user name: " git_name
        fi
        if [ -z "$git_email" ]; then
            read -rp "Git email: " git_email
        fi
    fi
    if [ -z "$git_name" ] || [ -z "$git_email" ]; then
        warn "Git identity not configured. Export GIT_USER_NAME and GIT_USER_EMAIL, run install.sh without --force, or edit $local_config."
        return 0
    fi
    if [ "$DRY_RUN" = true ]; then
        info "[DRY-RUN] Would set user.name/user.email in $local_config"
        return 0
    fi
    if [ ! -f "$local_config" ]; then
        cat > "$local_config" <<EOF_LOCAL
# ~/.gitconfig.local — machine-specific Git settings (not tracked by dotfiles-linux)
# Uncomment to enforce the gitflow hooks on every repository of this machine:
#[core]
#    hooksPath = $SCRIPT_DIR/git-hooks
EOF_LOCAL
    fi
    git config --file "$local_config" user.name "$git_name"
    git config --file "$local_config" user.email "$git_email"
    success "Configured Git identity in $local_config"
}

install_with_stow() {
    info "Using GNU Stow for symlinks..."
    for package_dir in "$CONFIG_DIR"/*/; do
        local package
        package=$(basename "$package_dir")
        if [ "$DRY_RUN" = true ]; then
            info "[DRY-RUN] Would stow: $package"
            stow -n -v -d "$CONFIG_DIR" -t "$HOME" "$package" 2>&1 || true
        else
            # Unstow first to handle re-runs
            stow -D -d "$CONFIG_DIR" -t "$HOME" "$package" 2>/dev/null || true
            stow -v -d "$CONFIG_DIR" -t "$HOME" "$package"
            success "Stowed: $package"
        fi
    done
}

install_manual() {
    info "Stow not found. Using manual symlinks..."
    for package_dir in "$CONFIG_DIR"/*/; do
        local package
        package=$(basename "$package_dir")
        # Find all files recursively in the package dir
        while IFS= read -r -d '' file; do
            local rel_path="${file#"$package_dir"}"
            local target="$HOME/$rel_path"
            backup_file "$target"
            mkdir -p "$(dirname "$target")"
            if [ "$DRY_RUN" = true ]; then
                info "[DRY-RUN] Would link: $target -> $file"
            else
                ln -sf "$file" "$target"
                success "Linked: $target -> $file"
            fi
        done < <(find "$package_dir" -type f -print0)
    done
}

# Carry the documented machine-specific keys of a pre-existing ~/.gitconfig
# (regular file or symlink to another manager's file) into ~/.gitconfig.local before the tracked file replaces it.
# Only keys missing from the local file are copied; everything else stays in
# the backup so shared defaults are not silently overridden.
migrate_git_settings() {
    local local_config="$HOME/.gitconfig.local" old_config="$HOME/.gitconfig" key value
    command -v git >/dev/null 2>&1 || return 0
    [ -f "$old_config" ] || return 0
    # A symlink is read through (another dotfiles manager may own the target);
    # only a link that already points at this repository's file has nothing to carry.
    if [ -L "$old_config" ] && [ "$(readlink -f "$old_config")" = "$(readlink -f "$CONFIG_DIR/git/.gitconfig")" ]; then
        return 0
    fi
    for key in core.hooksPath credential.helper; do
        if git config --file "$local_config" --get "$key" >/dev/null 2>&1; then
            continue
        fi
        while IFS= read -r value; do
            [ -n "$value" ] || continue
            if [ "$DRY_RUN" = true ]; then
                info "[DRY-RUN] Would carry $key=$value into $local_config"
            else
                git config --file "$local_config" --add "$key" "$value"
                info "Carried $key from $old_config into $local_config"
            fi
        done < <(git config --file "$old_config" --get-all "$key" 2>/dev/null || true)
    done
}

# Main
setup_git_config
migrate_git_settings

if command -v stow &>/dev/null; then
    # Backup conflicting files before stow
    for package_dir in "$CONFIG_DIR"/*/; do
        while IFS= read -r -d '' file; do
            rel_path="${file#"$package_dir"}"
            backup_file "$HOME/$rel_path"
        done < <(find "$package_dir" -type f -print0)
    done
    install_with_stow
else
    install_manual
fi

if [ -d "$BACKUP_DIR" ]; then
    info "Backups saved to: $BACKUP_DIR"
fi

success "Dotfiles installation complete!"
