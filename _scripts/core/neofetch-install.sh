#!/bin/bash

###
# neofetch install script
###

if [[ -z "$VV" ]]; then
  ## Init
  if [[ -d "${0%/*}" ]]; then
    DIR=${0%/*}
  else
    DIR="$PWD";
  fi

  ## Includes
  . "$DIR/helpers.sh"
fi

install_package "neofetch" "neofetch --version"

