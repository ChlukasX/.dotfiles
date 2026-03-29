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

detect_pkg_manager() {
    if command -v pacman &>/dev/null; then echo "pacman"
    elif command -v apt &>/dev/null;   then echo "apt"
    elif command -v dnf &>/dev/null;   then echo "dnf"
    else echo "unknown"; fi
}

install_packages() {
    local pkgfile=""
    local mgr
    mgr=$(detect_pkg_manager)

    case "$mgr" in
        pacman) pkgfile="$DOTFILES/packages/pkgs.pacman" ;;
        apt)    pkgfile="$DOTFILES/packages/pkgs.apt"    ;;
        dnf)    pkgfile="$DOTFILES/packages/pkgs.dnf"    ;;
        *)      warn "Unknown package manager, skipping package install."; return ;;
    esac

    if [ ! -f "$pkgfile" ]; then
        warn "No package list found at $pkgfile — skipping."
        return
    fi

    info "Installing packages via $mgr..."
    case "$mgr" in
        pacman) sudo pacman -S --needed - < "$pkgfile" ;;
        apt)    xargs sudo apt install -y < "$pkgfile"  ;;
        dnf)    xargs sudo dnf install -y < "$pkgfile"  ;;
    esac
}

update_repo() {
    info "Updating dotfiles..."
    cd "$DOTFILES"
    git fetch --quiet
    git pull --quiet --ff-only || warn "Could not fast-forward; skipping pull."
}

link_wm() {
    case "$1" in
        i3)
            safe_link "$DOTFILES/config/i3"      "$CONFIG/i3"
            safe_link "$DOTFILES/config/i3status" "$CONFIG/i3status"
            ;;
        hypr)
            safe_link "$DOTFILES/config/hypr"    "$CONFIG/hypr"
            safe_link "$DOTFILES/config/waybar"  "$CONFIG/waybar"
            ;;
        sway)
            safe_link "$DOTFILES/config/sway"      "$CONFIG/sway"
            safe_link "$DOTFILES/config/waybar"    "$CONFIG/waybar"
            safe_link "$DOTFILES/config/swaylock"  "$CONFIG/swaylock"
            safe_link "$DOTFILES/config/wofi"      "$CONFIG/wofi"
            safe_link "$DOTFILES/config/dunst"      "$CONFIG/dunst"
            ;;
        *)
            warn "No WM specified. Skipping WM config. Usage: $0 [i3|hypr|sway]"
            ;;
    esac
}

link_configs() {
    info "Linking configs..."
    safe_link "$DOTFILES/config/nvim"            "$CONFIG/nvim"
    safe_link "$DOTFILES/config/wezterm"         "$CONFIG/wezterm"
    safe_link "$DOTFILES/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
    safe_link "$DOTFILES/config/tmux/plugins"    "$HOME/.tmux/plugins"
    safe_link "$DOTFILES/config/zsh/.zshrc"      "$HOME/.zshrc"
}

main() {
    update_repo
    install_packages
    link_wm "${1:-}"
    link_configs
    info "Done!"
}

main "$@"
