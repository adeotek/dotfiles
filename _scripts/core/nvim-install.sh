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
# . "$CDIR/python-install.sh"

case $CURRENT_OS_ID in
  arch)
    sudo pacman -R --noconfirm vim
    sudo pacman -S --noconfirm --needed luarocks # python-neovim
    install_package "neovim" "nvim -v"
  ;;
  debian|ubuntu)
    sudo apt install -y luarocks # python-neovim
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      sudo apt install -y ninja-build gettext cmake unzip curl build-essential
      sudo -i
      if [ ! -d "/opt/neovim-src" ]; then
        mkdir /opt/neovim-src
        git clone https://github.com/neovim/neovim /opt/neovim-src
      fi
      cd /opt/neovim-src
      git checkout master
      git pull
      git checkout stable
      make CMAKE_BUILD_TYPE=RelWithDebInfo
      cd build && cpack -G DEB && dpkg -i nvim-linux64.deb
      cd ~
      exit
    else
      . "$CDIR/homebrew-install.sh"
      install_package "neovim" "nvim -v" "brew install neovim"
    fi
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

sudo npm install -g neovim
sudo npm install -g tree-sitter-cli
