#!/bin/bash

###
# zsh install script
###

if [[ -z "$VV" ]]; then
  ## Init
  if [[ -d "${0%/*}" ]]; then
    DIR=${0%/*}
  else
    DIR="$PWD";
  fi

  ## Includes
  . "$DIR/core/helpers.sh"
fi

install_package "zsh" "zsh --version"

