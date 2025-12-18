#!/bin/bash

update_repo() {
    cd ~/.dotfiles && git fetch && git pull
}

#update_repo

case "$1" in
    "i3")
        ln -sf ~/.dotfiles/config/i3 ~/.config/i3
        ln -sf ~/.dotfiles/config/i3status ~/.config/i3status
        ;;
    "hypr")
        ln -sf ~/.dotfiles/config/hypr ~/.config/hypr
        ln -sf ~/.dotfiles/config/waybar ~/.config/waybar
        ;;
esac

ln -sf ~/.dotfiles/config/nvim ~/.config/nvim
ln -sf ~/.dotfiles/config/wezterm ~/.config/wezterm
ln -sf ~/.dotfiles/config/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/config/tmux/plugins ~/.tmux/plugins
ln -sf ~/.dotfiles/config/zsh/.zshrc ~/.zshrc
