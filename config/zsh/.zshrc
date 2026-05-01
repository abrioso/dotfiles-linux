# ~/.zshrc — Managed by dotfiles-linux
# https://github.com/abrioso/dotfiles-linux

# --- Path ---
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic"

# Conditional plugin loading
plugins=(git sudo z history-substring-search)
command -v docker &>/dev/null && plugins+=(docker)
command -v kubectl &>/dev/null && plugins+=(kubectl)

# External plugins (loaded if installed)
[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ] && plugins+=(zsh-autosuggestions)
[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ] && plugins+=(zsh-syntax-highlighting)

# Load Oh My Zsh
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# --- Aliases ---
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'
alias reload='source ~/.zshrc'

# Modern replacements (use if available)
command -v bat &>/dev/null && alias cat='bat --paging=never'
command -v eza &>/dev/null && alias ls='eza --icons' && alias ll='eza -la --icons'
command -v fd &>/dev/null && alias find='fd'

# --- History ---
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# --- Key bindings ---
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- Starship prompt (overrides ZSH_THEME if installed) ---
command -v starship &>/dev/null && eval "$(starship init zsh)"

# --- fzf ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- Local overrides ---
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
