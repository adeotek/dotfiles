#!/bin/bash

###
# rtk install script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install rtk
source "$CDIR/homebrew-install.sh"
install_package "rtk" "brew list rtk" "brew install rtk"
