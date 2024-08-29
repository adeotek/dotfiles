#!/bin/bash

###
# OhMyPosh setup script
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
source "$CDIR/oh-my-posh-install.sh"
source "$CDIR/nerd-fonts-install.sh"

# Setup
stow_package "oh-my-posh" "" "$HOME/.config/oh-my-posh"
