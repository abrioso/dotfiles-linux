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
            echo "  --force    Skip backup prompts"
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
        local rel_path="${file#$HOME/}"
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

# Prompt for git config
setup_git_config() {
    local git_config="$CONFIG_DIR/git/.gitconfig"
    if grep -q "PLACEHOLDER" "$git_config" 2>/dev/null; then
        if [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
            read -rp "Git user name [abrioso]: " git_name
            git_name="${git_name:-abrioso}"
            read -rp "Git email [akbrioso@iseg.ulisboa.pt]: " git_email
            git_email="${git_email:-akbrioso@iseg.ulisboa.pt}"
        else
            git_name="abrioso"
            git_email="akbrioso@iseg.ulisboa.pt"
        fi
        if [ "$DRY_RUN" = false ]; then
            sed -i "s/NAME_PLACEHOLDER/$git_name/g" "$git_config"
            sed -i "s/EMAIL_PLACEHOLDER/$git_email/g" "$git_config"
        fi
    fi
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
            local rel_path="${file#$package_dir}"
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

# Main
setup_git_config

if command -v stow &>/dev/null; then
    # Backup conflicting files before stow
    for package_dir in "$CONFIG_DIR"/*/; do
        while IFS= read -r -d '' file; do
            local rel_path="${file#$package_dir}"
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
