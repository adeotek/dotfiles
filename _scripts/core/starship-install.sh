#!/bin/bash

###
# Starship install script
###

# Init
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/helpers.sh"
fi

# Install
. "$IDIR/homebrew-install.sh"
install_package "starship" "starship --version" "brew install starship"

