#!/bin/bash

###
# yazi install script
###

# Init
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/core/helpers.sh"
fi

# Install
case $CURRENT_OS_ID in
  arch)
    install_package "yazi" "yazi -V"
  ;;
  debian|ubuntu)
    . "$IDIR/homebrew-install.sh"
    install_package "yazi" "yazi -V" "brew install yazi"
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

