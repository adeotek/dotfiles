#!/bin/bash

###
# Starship setup script
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
. "$CDIR/starship-install.sh"

# Setup
stow_package "starship" "" "$CURRENT_CONFIG_DIR/starship"
