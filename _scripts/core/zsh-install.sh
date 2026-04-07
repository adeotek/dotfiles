#!/bin/bash

###
# zsh install script
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

# Install ZSH
install_package "zsh" "zsh --version"

# FZF and Zoxide are handled by the base tools install script.
source "$CDIR/base-tools-install.sh"

# Install Antidote via Homebrew
source "$CDIR/homebrew-install.sh"
install_package "antidote" "brew list antidote" "brew install antidote"
