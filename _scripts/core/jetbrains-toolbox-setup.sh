#!/bin/bash

###
# JetBrains Toolbox setup script
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
. "$CDIR/jetbrains-toolbox-install.sh"

# Setup
decho "yellow" "No config available to stow for JetBrains Toolbox!"

