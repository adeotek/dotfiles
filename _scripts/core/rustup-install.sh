#!/bin/bash

###
# rustup install script
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
cecho "cyan" "Installing [rustup]..."
if [ "$DRY_RUN" -ne "1" ]; then
  if [[ ! -x "$(command -v rustc)" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    rustup update
    cecho "green" "[rustup] installation done."
  else
    cecho "yellow" "[rustup] is already present."
  fi
else
  cecho "yellow" "DRY-RUN: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  cecho "yellow" "DRY-RUN: rustup update" 
fi
