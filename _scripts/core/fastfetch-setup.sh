#!/bin/bash

###
# fastfetch setup script
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
source "$CDIR/fastfetch-install.sh"

# Setup
stow_package "fastfetch" "" "$CURRENT_CONFIG_DIR/fastfetch"
