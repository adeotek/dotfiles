#!/bin/bash

###
# OhMyPosh install script
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

# Install
source "$CDIR/nerd-fonts-install.sh"

cecho "cyan" "Installing [oh-my-posh]..."
if command -v oh-my-posh >/dev/null 2>&1; then
  decho "yellow" "Package already installed. Updating it..."
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  decho "magenta" "curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin"
  if ! (set -o pipefail; curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin); then
    cecho "red" "[oh-my-posh] installation failed."
    return 1
  fi
  cecho "green" "[oh-my-posh] installation done."
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://ohmyposh.dev/install.sh | sudo bash -s -- -d /usr/local/bin"
fi
