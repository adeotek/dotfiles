#!/bin/bash

###
# Kitty setup script
###

# Init
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "${0%/*}")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
. "$CDIR/kitty-install.sh"
. "$CDIR/nerd-fonts-install.sh"

# Setup
stow_package "kitty" "" "$CURRENT_CONFIG_DIR/kitty"
