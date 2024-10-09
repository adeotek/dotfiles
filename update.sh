#!/bin/bash

###
# AdeoTEK dotfiles update
###

# Init
if [[ -d "${0%/*}" ]]; then
  RDIR="${0%/*}"
else
  RDIR="$PWD";
fi
CDIR="$RDIR/_scripts/core";

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

