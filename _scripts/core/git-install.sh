#!/bin/bash

###
# Git install script
###

# Init
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/helpers.sh"
fi

# Install
install_package "git" "git -v"
