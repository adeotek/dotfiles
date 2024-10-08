#!/bin/bash

###
# Git setup script
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
. "$CDIR/git-install.sh"

# Setup
stow_package "git" "" "$CURRENT_CONFIG_DIR/git"
# Add GitHub SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi
