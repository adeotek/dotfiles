#!/bin/bash

###
# OhMyPosh install script
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
. "$CDIR/homebrew-install.sh"
install_package "oh-my-posh" "oh-my-posh --version" "brew install jandedobbeleer/oh-my-posh/oh-my-posh"

