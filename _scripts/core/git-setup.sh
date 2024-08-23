#!/bin/bash

###
# Git setup script
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
. "$CDIR/git-install.sh"

# Setup
stow_package "git" "" "$HOME/.config/git"
# Add GitHub SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi
