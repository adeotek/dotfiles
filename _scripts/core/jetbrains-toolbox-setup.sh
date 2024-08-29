#!/bin/bash

###
# JetBrains Toolbox setup script
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
. "$CDIR/jetbrains-toolbox-install.sh"

# Setup
decho "yellow" "No config available to stow for JetBrains Toolbox!"

