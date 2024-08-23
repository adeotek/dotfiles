#!/bin/bash

###
# Tabby setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/_helpers.sh"
fi

# Install
cecho "yellow" "WARNING: Tabby setup not implemented yet!"
