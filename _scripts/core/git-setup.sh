#!/bin/bash

###
# Git setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/helpers.sh"
fi

# Install
. "$SDIR/git-install.sh"

# Setup
stow_package "git" "" "$HOME/.config/git"
# Add GitHub SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi
