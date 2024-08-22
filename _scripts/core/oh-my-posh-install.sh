#!/bin/bash

###
# OhMyPosh install script
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
. "$IDIR/homebrew-install.sh"
install_package "oh-my-posh" "oh-my-posh --version" "brew install jandedobbeleer/oh-my-posh/oh-my-posh"

