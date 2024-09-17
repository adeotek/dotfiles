#!/bin/bash

###
# OhMyPosh install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "cyan" "Installing [oh-my-posh]..."
if [ oh-my-posh --version >/dev/null 2>&1 ]; then
  decho "yellow" "Package already installed. Updating it..."
fi

if [ "$DRY_RUN" -ne "1" ]; then
  decho "magenta" "curl -s https://ohmyposh.dev/install.sh | sudo bash -s"
  curl -s https://ohmyposh.dev/install.sh | sudo bash -s
  cecho "green" "[oh-my-posh] installation done."
else
  cecho "yellow" "DRY-RUN: curl -s https://ohmyposh.dev/install.sh | sudo bash -s"
fi

