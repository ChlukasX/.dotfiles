#! /bin/bash

if command -v brew &> /dev/null; then
    echo "Homebrew is installed"
else
    echo "Homebrew is not installed"
    echo "Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

sleep 2
echo "Installing packages"

# todo error handling
brew install nvim tmux wezterm aerospace

sleep 2
echo "linking .dotfiles to ~/.config..."

# Create if does not exist already
mkdir -p ~/.config

# tmux goes to root and links file
ln -s ~/.dotfiles/.config/tmux/.tmux.conf ~/

# links to .config that are dirs
ln -s ~/.dotfiles/.config/aerospace ~/.config/
ln -s ~/.dotfiles/.config/nvim ~/.config/
ln -s ~/.dotfiles/.config/wezterm ~/.config/

# todo .zshrc
