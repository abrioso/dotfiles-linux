#!/bin/bash
# bootstrap.sh — First-run setup for a fresh Linux system
# Usage: ./bootstrap.sh [--minimal]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MINIMAL=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --minimal) MINIMAL=true ;;
        --help|-h)
            echo "Usage: ./bootstrap.sh [--minimal]"
            echo "  --minimal  Skip GUI packages (for servers)"
            exit 0
            ;;
    esac
done

# Colors
info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
success() { printf '\033[1;32m[ OK ]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1" >&2; }

# Source distro detection
# shellcheck source=scripts/detect-distro.sh
source "$SCRIPT_DIR/scripts/detect-distro.sh"
DISTRO=$(detect_distro)

info "Detected distro family: $DISTRO"
info "Minimal mode: $MINIMAL"

if [ "$DISTRO" = "unknown" ]; then
    error "Unsupported distribution. Exiting."
    exit 1
fi

# Install minimum dependencies
info "Installing minimum dependencies (git, curl, stow, zsh)..."
case "$DISTRO" in
    debian)
        sudo apt-get update -qq
        sudo apt-get install -y git curl stow zsh
        ;;
    rhel)
        sudo dnf install -y git curl stow zsh
        ;;
    arch)
        sudo pacman -Sy --noconfirm git curl stow zsh
        ;;
esac
success "Minimum dependencies installed."

# Install packages
info "Installing packages..."
"$SCRIPT_DIR/scripts/install-packages.sh" "$MINIMAL"
success "Packages installed."

# Post-install (Oh My Zsh, starship, plugins)
info "Running post-install..."
"$SCRIPT_DIR/scripts/post-install.sh"
success "Post-install complete."

# Run dotfile installer
info "Installing dotfiles..."
"$SCRIPT_DIR/install.sh" --force
success "Dotfiles installed."

echo ""
success "Bootstrap complete! Restart your shell or run: exec zsh"
