#!/bin/bash

###
# Zed setup script
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
. "$CDIR/zed-install.sh"

# Setup
stow_package "zed" "" "$CURRENT_CONFIG_DIR/zed"
