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
    sudo pacman -S --noconfirm --needed ffmpegthumbnailer p7zip poppler imagemagick
    install_package "yazi" "yazi -V"
  ;;
  debian|ubuntu)
    . "$CDIR/homebrew-install.sh"
    brew install ffmpegthumbnailer sevenzip poppler imagemagick
    install_package "yazi" "yazi -V" "brew install yazi"
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

