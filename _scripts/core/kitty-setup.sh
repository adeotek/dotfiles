#!/bin/bash

###
# Kitty setup script
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
. "$CDIR/kitty-install.sh"
. "$CDIR/nerd-fonts-install.sh"

# Setup
stow_package "kitty" "" "$CURRENT_CONFIG_DIR/kitty"
