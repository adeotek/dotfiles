#!/bin/bash

###
# zsh setup script
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
. "$SDIR/zsh-install.sh"

# Setup
stow_package "zsh" "" "" "$HOME/.zshrc"

