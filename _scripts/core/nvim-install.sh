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
#. "$CDIR/nodejs-install.sh"
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
      if [ ! -d "/opt/neovim-src" ]; then
        sudo mkdir /opt/neovim-src
        sudo git clone https://github.com/neovim/neovim /opt/neovim-src
      fi
      cd /opt/neovim-src
      sudo git checkout master
      sudo git pull
      sudo git checkout stable
      sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
      cd build && sudo cpack -G DEB && sudo dpkg -i nvim-linux64.deb
      cd ~
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
