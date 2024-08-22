#!/bin/bash

###
# tmux install script
###

# Init
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/core/helpers.sh"
fi

# Install
install_package "tmux" "tmux -V"

