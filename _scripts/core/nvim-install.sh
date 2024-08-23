#!/bin/bash

###
# NeoVim install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
. "$CDIR/nodejs-install.sh"

case $CURRENT_OS_ID in
  arch)
    sudo pacman -R --noconfirm vim
    sudo pacman -S --noconfirm --needed luarocks python-neovim
    install_package "neovim" "nvim -v"
  ;;
  debian|ubuntu)
    . "$CDIR/homebrew-install.sh"
    sudo apt install -y luarocks python-neovim
    install_package "neovim" "nvim -v" "brew install neovim"
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

npm install -g neovim
npm install -g tree-sitter-cli
