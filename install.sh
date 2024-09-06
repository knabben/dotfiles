#!/bin/bash

# Set WSL2 user
USER=aknabben

# Install default required packages
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install tmux vim zsh make python3 python3-pip ipython fzf

# Set ZSH
chsh -s /bin/zsh

# Starship installation
curl -sS https://starship.rs/install.sh | sh
# Copy tmux and zsh files
cp -r .zshrc .zshenv .oh-my-zsh .tmux .tmux.conf /home/$USER
sudo cp sudoers /etc/sudoers.d/$USER

# Install Neovim
if [ ! -f "nvim-linux64.tar.gz" ]; then
  wget https://github.com/neovim/neovim/releases/download/v0.10.1/nvim-linux64.tar.gz
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.zshrc
fi

# LunarVIM installation
LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
