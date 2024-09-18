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
source "$CDIR/nodejs-install.sh"

case $CURRENT_OS_ID in
  arch)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo pacman -R --noconfirm vim
      sudo pacman -S --noconfirm --needed luarocks # python-neovim
    else
      cecho "yellow" "DRY-RUN: sudo pacman -R --noconfirm vim"
      cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed luarocks"
    fi
    install_package "neovim" "nvim -v"
  ;;
  debian|ubuntu)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo apt install -y luarocks # python-neovim
    else
      cecho "yellow" "DRY-RUN: sudo apt install -y luarocks"
    fi
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      cecho "cyan" "Installing [neovim]..."
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo apt install -y ninja-build gettext cmake unzip curl build-essential
        if [ ! -d "/opt/neovim-src" ]; then
          sudo git clone https://github.com/neovim/neovim /opt/neovim-src
        fi
        cd /opt/neovim-src
        sudo git checkout master
        sudo git pull
        sudo git checkout stable
        sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
        cd build && sudo cpack -G DEB && sudo dpkg -i nvim-linux64.deb
        cd ~
        cecho "green" "[nodejs] installation done."
      else
        cecho "yellow" "DRY-RUN: sudo apt install -y ninja-build gettext cmake unzip curl build-essential"
        cecho "yellow" "DRY-RUN: sudo git clone https://github.com/neovim/neovim /opt/neovim-src"
        cecho "yellow" "DRY-RUN: cd /opt/neovim-src"
        cecho "yellow" "DRY-RUN: sudo git checkout master"
        cecho "yellow" "DRY-RUN: sudo git pull"
        cecho "yellow" "DRY-RUN: sudo git checkout stable"
        cecho "yellow" "DRY-RUN: sudo make CMAKE_BUILD_TYPE=RelWithDebInfo"
        cecho "yellow" "DRY-RUN: cd build && sudo cpack -G DEB && sudo dpkg -i nvim-linux64.deb"
        cecho "yellow" "DRY-RUN: cd ~"
      fi
    else
      source "$CDIR/homebrew-install.sh"
      install_package "neovim" "nvim -v" "brew install neovim"
    fi
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

if [ "$DRY_RUN" -ne "1" ]; then
  sudo npm install -g neovim
  sudo npm install -g tree-sitter-cli
else
  cecho "yellow" "DRY-RUN: sudo npm install -g neovim"
  cecho "yellow" "DRY-RUN: sudo npm install -g tree-sitter-cli"
fi

