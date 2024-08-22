#!/bin/bash

###
# neofetch setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/core/helpers.sh"
fi

# Install
. "$SDIR/neofetch-install.sh"

# Setup
stow_package "neofetch" "" "$HOME/.config/neofetch"

