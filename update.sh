#!/bin/bash

###
# AdeoTEK dotfiles update
###

# Init
if [[ -d "${0%/*}" ]]; then
  CDIR="${0%/*}/_scripts/core"
else
  CDIR="$PWD/_scripts/core";
fi

## Includes
source "$CDIR/_helpers.sh"

## Startup
cecho "blue" "Starting dotfiles update..."

# Main
source "$CDIR/system-update.sh"

if [[ -x "$(command -v brew)" ]]; then
  brew upgrade
fi

if [[ -x "$(command -v npm)" ]]; then
  sudo npm install -g npm
fi

if [[ -x "$(command -v oh-my-posh)" ]]; then
  sudo oh-my-posh upgrade
fi

## End
cecho "blue" "DONE!"

