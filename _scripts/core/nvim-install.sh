#!/bin/bash

###
# NeoVim install script
###

# Init
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/helpers.sh"
fi

# Install
. "$IDIR/nodejs-install.sh"

case $CURRENT_OS_ID in
  arch)
    sudo pacman -R --noconfirm vim
    sudo pacman -S --noconfirm --needed luarocks python-neovim
    install_package "neovim" "nvim -v"
  ;;
  debian|ubuntu)
    . "$IDIR/homebrew-install.sh"
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
