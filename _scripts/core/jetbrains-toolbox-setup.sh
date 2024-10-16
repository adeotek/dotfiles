#!/bin/bash

###
# JetBrains Toolbox setup script
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
source "$CDIR/jetbrains-toolbox-install.sh"

# Setup
decho "yellow" "No config available to stow for JetBrains Toolbox!"

