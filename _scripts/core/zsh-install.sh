#!/bin/bash

###
# zsh install script
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
install_package "zsh" "zsh --version"

## Install plugins and tools
install_package "zsh-syntax-highlighting" "_"
install_package "zsh-autosuggestions" "_"
