#!/bin/bash

###
# mise install script
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

# Install mise
cecho "cyan" "Installing [mise]..."
if [ "$DRY_RUN" -ne "1" ]; then
  curl https://mise.run | sh
  cecho "green" "[mise] installation done."
else
  cecho "yellow" "DRY-RUN: curl https://mise.run | sh"
fi
