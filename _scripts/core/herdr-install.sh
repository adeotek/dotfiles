#!/bin/bash

###
# herdr install script
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

# Install herdr
cecho "cyan" "Installing [herdr]..."
if [ "$DRY_RUN" -ne "1" ]; then
  curl -fsSL https://herdr.dev/install.sh | sh
  cecho "green" "[herdr] installation done."
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://herdr.dev/install.sh | sh"
fi
