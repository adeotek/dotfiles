#!/bin/bash

###
# bash setup script
###

# Init
declare -A ARGS=(
    ["prompt"]=""
)
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}/_scripts/core"
  else
    CDIR="$PWD/_scripts/core";
  fi
  source "$CDIR/_helpers.sh"
fi
process_args $@

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  . "$CDIR/oh-my-posh-install.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  . "$CDIR/starship-install.sh"
fi
stow_package "bash" "" "" "$HOME/.bashrc"

