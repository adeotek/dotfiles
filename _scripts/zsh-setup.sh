#!/bin/bash

###
# zsh setup script
###

if [[ -z "$VV" ]]; then
  ## Init
  if [[ -d "${0%/*}" ]]; then
    DIR=${0%/*}
  else
    DIR="$PWD";
  fi

  ## Includes
  . "$DIR/core/helpers.sh"
fi

# Install
. "$DIR/zsh-install.sh"

# Setup
stow_package "zsh" "" "" "$HOME/.zshrc"

