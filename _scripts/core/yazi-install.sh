#!/bin/bash

###
# yazi install script
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
case $CURRENT_OS_ID in
  arch)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo pacman -S --noconfirm --needed ffmpegthumbnailer p7zip poppler imagemagick
    else

    fi
    install_package "yazi" "yazi -V"
  ;;
  debian|ubuntu)
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      source "$CDIR/rustup-install.sh"
      cecho "cyan" "Installing [yazi]..."
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo apt install -y make gcc
        cargo install --locked yazi-fm yazi-cli
        cecho "green" "[yazi] installation done."
      else
        cecho "yellow" "DRY-RUN: cargo install --locked yazi-fm yazi-cli"
        cecho "yellow" "DRY-RUN: sudo apt install -y make gcc"
      fi
    else
      . "$CDIR/homebrew-install.sh"
      brew install ffmpegthumbnailer sevenzip poppler imagemagick
      install_package "yazi" "yazi -V" "brew install yazi"
    fi
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

