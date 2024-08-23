#!/bin/bash

###
# NeoVim setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/_helpers.sh"
fi

# Install
. "$SDIR/nvim-install.sh"

# Setup
stow_package "nvim" "" "$HOME/.config/nvim"
