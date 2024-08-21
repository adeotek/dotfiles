#!/bin/bash

###
# AdeoTEK dot files setup
###

## Init
if [[ -d "${0%/*}" ]]; then
  DIR=${0%/*}
else
  DIR="$PWD";
fi

## Includes
. "$DIR/_scripts/helpers.sh"

## Startup debug 
decho "blue" "Starting $ACTION..."

# Main
# . "$DIR/nvim-setup.sh"
stow_package git
stow_package kitty

## End
decho "blue" "DONE!"

