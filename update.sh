#!/bin/bash

###
# AdeoTEK dotfiles update
###

# shellcheck disable=SC1091

# Init
if [[ -d "${0%/*}" ]]; then
  RDIR="$(cd "${0%/*}" && pwd)"
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

if [[ -x "$(command -v flatpak)" ]]; then
  flatpak update -y
fi

if [[ -x "$(command -v brew)" ]]; then
  brew upgrade -y
fi

if [[ -x "$(command -v npm)" ]]; then
  sudo npm install -g npm
fi

if [[ -x "$(command -v uv)" ]]; then
  uv self update
  uv tool upgrade --all
fi

if [[ -x "$(command -v oh-my-posh)" ]]; then
  sudo oh-my-posh upgrade
fi

## End
cecho "blue" "DONE!"

