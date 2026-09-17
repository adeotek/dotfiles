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
cecho "blue" "Starting dotfiles v2 update..."

# Main
source "$CDIR/system-update.sh"

if [[ -x "$(command -v flatpak)" ]]; then
  execute_command "flatpak update -y" "flatpak updated."
fi

if [[ -x "$(command -v brew)" ]]; then
  execute_command "brew upgrade -y" "Homebrew packages upgraded."
fi

if [[ -x "$(command -v npm)" ]]; then
  execute_command "sudo npm install -g npm" "npm updated."
fi

if [[ -x "$(command -v uv)" ]]; then
  execute_command "uv self update && uv tool upgrade --all" "uv updated."
fi

if [[ -x "$(command -v oh-my-posh)" ]]; then
  execute_command "sudo oh-my-posh upgrade" "oh-my-posh updated."
fi

## End
cecho "blue" "DONE!"
