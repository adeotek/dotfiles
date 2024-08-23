#!/bin/bash

###
# zsh setup script
###

# Init
declare -A ARGS=(
    ["prompt"]=""
)
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi
process_args $@

# Install
source "$CDIR/zsh-install.sh"

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "zsh" "" "" "$HOME/.zshrc"
