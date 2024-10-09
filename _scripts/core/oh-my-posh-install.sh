#!/bin/bash

###
# OhMyPosh install script
###

# Init
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
source "$CDIR/nerd-fonts-install.sh"

cecho "cyan" "Installing [oh-my-posh]..."
if [ oh-my-posh --version >/dev/null 2>&1 ]; then
  decho "yellow" "Package already installed. Updating it..."
fi

if [ "$DRY_RUN" -ne "1" ]; then
  decho "magenta" "curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin"
  curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin
  cecho "green" "[oh-my-posh] installation done."
else
  cecho "yellow" "DRY-RUN: curl -s https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin"
fi

