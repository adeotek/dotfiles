#!/bin/bash

###
# NeoVim dot files setup
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

## Startup debug
decho "cyan" "Running nvim $ACTION..."

## Main

STOW_COMMAND=$(get_stow_command nvim)
decho "magenta" "$STOW_COMMAND"
if [ "$DRY_RUN" -ne "1" ]; then
  . "$STOW_COMMAND"
fi

cecho "green" "nvim setup done"

