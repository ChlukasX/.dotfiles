#!/bin/bash

set -euo pipefail

DOTFILES="$HOME/.dotfiles"
CONFIG="$HOME/.config"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${GREEN}[info]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
error() { echo -e "${RED}[error]${NC} $*"; }

safe_link() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        info "Already linked: $dst"
        return
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
        warn "Backing up: $dst → $backup"
        mv "$dst" "$backup"
    fi

    if [ -L "$dst" ]; then
        warn "Removing stale symlink: $dst"
        rm "$dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    info "Linked: $dst → $src"
}

update_repo() {
    info "Updating dotfiles..."
    cd "$DOTFILES"
    git fetch --quiet
    git pull --quiet --ff-only || warn "Could not fast-forward; skipping pull."
}

install_homebrew() {
    if command -v brew &>/dev/null; then
        info "Homebrew already installed. Updating..."
        brew update --quiet
    else
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
}

install_brew_packages() {
    local brewfile="$DOTFILES/Brewfile"
    if [ -f "$brewfile" ]; then
        info "Installing packages from Brewfile..."
        brew bundle install --file="$brewfile" --no-lock
    else
        warn "No Brewfile found at $brewfile — skipping."
        warn "Run: brew bundle dump --file=$brewfile"
    fi
}

link_configs() {
    info "Linking configs..."
    safe_link "$DOTFILES/config/nvim"            "$CONFIG/nvim"
    safe_link "$DOTFILES/config/wezterm"         "$CONFIG/wezterm"
    safe_link "$DOTFILES/config/aerospace/.aerospace.toml"       "$HOME/.aerospace.toml"
    safe_link "$DOTFILES/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
    safe_link "$DOTFILES/config/zsh/.zshrc"      "$HOME/.zshrc"
}

main() {
    update_repo
    install_homebrew
    install_brew_packages
    link_configs
    info "Done!"
}

main "$@"
