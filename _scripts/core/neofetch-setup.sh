#!/bin/bash

###
# neofetch setup script
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
. "$CDIR/neofetch-install.sh"

# Setup
stow_package "neofetch" "" "$HOME/.config/neofetch"

