#!/bin/bash
# post-install.sh — Install Oh My Zsh, starship, and other extras
set -euo pipefail

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    info "Oh My Zsh already installed."
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    info "Starship already installed."
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    chsh -s "$(which zsh)" || warn "Could not change shell. Run: chsh -s \$(which zsh)"
fi

info "Post-install complete!"
