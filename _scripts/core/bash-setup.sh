#!/bin/bash

###
# bash setup script
###

# Init
declare -A ARGS=(
    ["prompt"]=""
)
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/helpers.sh"
fi

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  . "$SDIR/oh-my-posh-install.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  . "$SDIR/starship-install.sh"
fi
stow_package "bash" "" "" "$HOME/.bashrc"

