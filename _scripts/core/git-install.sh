#!/bin/bash

###
# Git install script
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

# Guard: skip installation when git is already available
if command -v git >/dev/null 2>&1; then
  cecho "yellow" "[git] is already present. Skipping installation."
  return 0
fi

# Install
install_package "git" "git -v"
