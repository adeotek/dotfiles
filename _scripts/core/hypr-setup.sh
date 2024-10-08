#!/bin/bash

###
# hyprland setup script
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

# Setup
stow_package "hypr" "" "$CURRENT_CONFIG_DIR/hypr"
