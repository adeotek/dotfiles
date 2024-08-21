#!/bin/bash

###
# tmux setup script
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
. "$DIR/tmux-install.sh"

# Setup
stow_package "tmux" "" "$HOME/.config/tmux"

