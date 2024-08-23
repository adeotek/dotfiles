#!/bin/bash

###
# NeoVim setup script
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
. "$CDIR/nvim-install.sh"

# Setup
stow_package "nvim" "" "$HOME/.config/nvim"
