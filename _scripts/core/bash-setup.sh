#!/bin/bash

###
# bash setup script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["prompt"]=""
else
  declare -A ARGS=(["prompt"]="")
fi
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

process_args $@

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "bash" "" "" "$HOME/.bashrc"

