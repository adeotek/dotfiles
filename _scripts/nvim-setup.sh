#!/bin/bash

###
# NeoVim dot files setup
###

## Init
declare -A ARGS=(
    ["action"]=""
)
if [[ -d "${0%/*}" ]]; then
  DIR=${0%/*}
else
  DIR="$PWD";
fi

# Includes
. "$DIR/helpers.sh"
secho "ARGS:"
for x in "${!ARGS[@]}"; do secho ">>$x: ${ARGS[$x]}" ; done

## Main
secho "stow --dir="$HOME/.dotfiles" --target="$HOME" ${ARGS["action"]} nvim $(get_vv)"
stow --dir="$HOME/.dotfiles" --target="$HOME" ${ARGS["action"]} nvim $VERBOSE
