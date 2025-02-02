#!/bin/bash

###
# yazi install script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
case $CURRENT_OS_ID in
  arch)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo pacman -S --noconfirm --needed ffmpegthumbnailer p7zip poppler imagemagick
    else
      cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed ffmpegthumbnailer p7zip poppler imagemagick" 
    fi
    install_package "yazi" "yazi -V"
    ;;
  debian|ubuntu|pop)
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
      source "$CDIR/homebrew-install.sh"
      if [ "$DRY_RUN" -ne "1" ]; then
        brew install ffmpegthumbnailer sevenzip poppler imagemagick
      else
        cecho "yellow" "DRY-RUN: brew install ffmpegthumbnailer sevenzip poppler imagemagick"
      fi
      install_package "yazi" "yazi -V" "brew install yazi"
    fi
    ;;
  fedora|redhat|centos|almalinux)
    source "$CDIR/homebrew-install.sh"
    if [ "$DRY_RUN" -ne "1" ]; then
      brew install ffmpegthumbnailer sevenzip poppler imagemagick
    else
      cecho "yellow" "DRY-RUN: brew install ffmpegthumbnailer sevenzip poppler imagemagick"
    fi
    install_package "yazi" "yazi -V" "brew install yazi"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac

