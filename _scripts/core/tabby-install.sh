#!/bin/bash

###
# Tabby install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}/_scripts/core"
  else
    CDIR="$PWD/_scripts/core";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "yellow" "WARNING: Tabby install not implemented yet!"
