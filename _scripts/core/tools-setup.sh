#!/bin/bash

###
# tools setup script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi

# Setup
if ! stow --version >/dev/null 2>&1; then
  install_package "stow" "stow --version"
fi

stow_package "tools" "" "$HOME/.tools"
