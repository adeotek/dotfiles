#!/bin/bash

###
# Git setup script
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
source "$CDIR/git-install.sh"

# Setup
# Copy default user.config, if it doesn't exists
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p ~/.config/git.user
  if [[ ! -f ~/.config/git.user/config ]]; then
    cecho "cyan" "Copying git.user/config file..."
    if ! cp "$RDIR/_extra/git.user.config" ~/.config/git.user/config; then
      cecho "red" "Failed to copy git.user/config file."
    fi
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/_extra/git.user.config ~/.config/git.user/config (if not exists)"
fi

stow_package "git" "" "$CURRENT_CONFIG_DIR/git"

# Add GitHub SSH keys
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p ~/.ssh
  if ! grep -q "github.com" ~/.ssh/known_hosts 2>/dev/null; then
    if ! ssh-keyscan -H github.com >> ~/.ssh/known_hosts 2>/dev/null; then
      cecho "yellow" "WARNING: ssh-keyscan github.com failed."
    fi
  fi
else
  cecho "yellow" "DRY-RUN: ssh-keyscan -H github.com >> ~/.ssh/known_hosts"
fi
