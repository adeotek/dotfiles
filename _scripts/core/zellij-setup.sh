#!/bin/bash

###
# zellij setup script
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
source "$CDIR/zellij-install.sh"

# Setup
# Stow is not used for Zellij as it rewrites the config file on first run, so we need to copy our config before that happens.
# If the config file already exists, we assume the user has already set it up and we don't overwrite it.
if [ ! -e "$HOME/.config/zellij/config.kdl" ]; then
  cp "$RDIR/zellij/.config/zellij/config.gbs.kdl" "$HOME/.config/zellij/config.kdl"
else
  if [[ "${ARGS["unattended"]}" -ne "1" ]]; then
    echo "Zellij config already exists. Do you want to overwrite it? (y/N)"
    read -r overwrite_config
    if [[ "$overwrite_config" =~ ^[Yy]$ ]]; then
      cp "$RDIR/zellij/.config/zellij/config.gbs.kdl" "$HOME/.config/zellij/config.kdl"
      echo "Zellij config overwritten."
    fi
  fi
fi
