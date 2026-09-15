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
  if [[ "$DRY_RUN" -ne "1" ]]; then
    flatpak update -y
  else
    cecho "yellow" "DRY-RUN: flatpak update -y"
  fi
fi

if [[ -x "$(command -v brew)" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    brew upgrade -y
  else
    cecho "yellow" "DRY-RUN: brew upgrade -y"
  fi
fi

if [[ -x "$(command -v npm)" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    sudo npm install -g npm
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g npm"
  fi
fi

if [[ -x "$(command -v uv)" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    uv self update
    uv tool upgrade --all
  else
    cecho "yellow" "DRY-RUN: uv self update && uv tool upgrade --all"
  fi
fi

if [[ -x "$(command -v oh-my-posh)" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    sudo oh-my-posh upgrade
  else
    cecho "yellow" "DRY-RUN: sudo oh-my-posh upgrade"
  fi
fi

## End
cecho "blue" "DONE!"
