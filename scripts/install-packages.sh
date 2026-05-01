#!/bin/bash
# install-packages.sh — Install packages based on detected distro
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Source distro detection
# shellcheck source=detect-distro.sh
source "$SCRIPT_DIR/detect-distro.sh"

DISTRO=$(detect_distro)
MINIMAL="${1:-false}"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1"; }

install_packages() {
    local pkg_file="$1"
    if [ ! -f "$pkg_file" ]; then
        warn "Package file not found: $pkg_file"
        return 0
    fi

    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        line="${line%%#*}"
        line="${line// /}"
        [ -z "$line" ] && continue
        packages+=("$line")
    done < "$pkg_file"

    if [ ${#packages[@]} -eq 0 ]; then
        return 0
    fi

    info "Installing ${#packages[@]} packages from $(basename "$pkg_file")..."

    case "$DISTRO" in
        debian)
            sudo apt-get install -y "${packages[@]}" 2>/dev/null || {
                warn "Some packages failed; installing one by one..."
                for pkg in "${packages[@]}"; do
                    sudo apt-get install -y "$pkg" 2>/dev/null || warn "Failed: $pkg"
                done
            }
            ;;
        rhel)
            sudo dnf install -y "${packages[@]}" 2>/dev/null || {
                warn "Some packages failed; installing one by one..."
                for pkg in "${packages[@]}"; do
                    sudo dnf install -y "$pkg" 2>/dev/null || warn "Failed: $pkg"
                done
            }
            ;;
        arch)
            sudo pacman -S --noconfirm --needed "${packages[@]}" 2>/dev/null || {
                for pkg in "${packages[@]}"; do
                    sudo pacman -S --noconfirm --needed "$pkg" 2>/dev/null || warn "Failed: $pkg"
                done
            }
            ;;
        *)
            error "Unsupported distro: $DISTRO"
            return 1
            ;;
    esac
}

# Update package cache
info "Detected distro family: $DISTRO"
case "$DISTRO" in
    debian) sudo apt-get update -qq ;;
    rhel)   sudo dnf makecache -q ;;
    arch)   sudo pacman -Sy ;;
esac

# Install common packages
install_packages "$REPO_DIR/packages/common.txt"

# Install distro-specific packages
case "$DISTRO" in
    debian) install_packages "$REPO_DIR/packages/ubuntu.txt" ;;
    rhel)   install_packages "$REPO_DIR/packages/rhel.txt" ;;
esac

info "Package installation complete."
