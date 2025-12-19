
#!/bin/bash

update_repo() {
    cd ~/.dotfiles && git fetch && git pull
}

update_repo

ln -sf ~/.dotfiles/config/aerospace/.aerospace.toml ~/.aerospace.toml
ln -sf ~/.dotfiles/config/nvim ~/.config/nvim
ln -sf ~/.dotfiles/config/wezterm ~/.config/wezterm
ln -sf ~/.dotfiles/config/tmux/.tmux.conf ~/.tmux.conf
ln -sf ~/.dotfiles/config/zsh/.zshrc ~/.zshrc
