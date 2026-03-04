#!/bin/bash

###
# Ghostty setup script
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
source "$CDIR/ghostty-install.sh"
source "$CDIR/nerd-fonts-install.sh"

# Setup
stow_package "ghostty" "" "$CURRENT_CONFIG_DIR/ghostty"
