#!/bin/bash

###
# OhMyPosh install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}/_scripts/core"
  else
    CDIR="$PWD/_scripts/core";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
. "$CDIR/homebrew-install.sh"
install_package "oh-my-posh" "oh-my-posh --version" "brew install jandedobbeleer/oh-my-posh/oh-my-posh"

