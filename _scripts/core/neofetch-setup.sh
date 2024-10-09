#!/bin/bash

###
# neofetch setup script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
. "$CDIR/neofetch-install.sh"

# Setup
stow_package "neofetch" "" "$CURRENT_CONFIG_DIR/neofetch"

