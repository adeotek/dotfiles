#!/bin/bash

###
# Zed setup script
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
. "$CDIR/zed-install.sh"

# Setup
stow_package "zed" "" "$CURRENT_CONFIG_DIR/zed"
