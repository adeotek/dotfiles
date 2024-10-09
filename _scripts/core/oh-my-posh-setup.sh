#!/bin/bash

###
# OhMyPosh setup script
###

# Init
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
source "$CDIR/oh-my-posh-install.sh"

# Setup
stow_package "oh-my-posh" "" "$CURRENT_CONFIG_DIR/oh-my-posh"
