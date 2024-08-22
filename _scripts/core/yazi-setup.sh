#!/bin/bash

###
# yazi setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/helpers.sh"
fi

# Install
. "$SDIR/yazi-install.sh"

# Setup
stow_package "yazi" "" "$HOME/.config/yazi"

