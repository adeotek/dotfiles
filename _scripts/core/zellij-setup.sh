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
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/zellij/config.kdl" ]; then
    mkdir -p "$HOME/.config/zellij"
    if cp "$RDIR/zellij/.config/zellij/config.gbs.kdl" "$HOME/.config/zellij/config.kdl"; then
      cecho "green" "Zellij config created."
    else
      cecho "red" "Failed to create Zellij config."
    fi
  elif [[ "${ARGS["unattended"]}" -ne "1" ]]; then
    cecho "yellow" "Zellij config already exists. Do you want to overwrite it? (y/N)"
    read -r overwrite_config
    if [[ "$overwrite_config" =~ ^[Yy]$ ]]; then
      if cp "$RDIR/zellij/.config/zellij/config.gbs.kdl" "$HOME/.config/zellij/config.kdl"; then
        cecho "green" "Zellij config overwritten."
      else
        cecho "red" "Failed to overwrite Zellij config."
      fi
    fi
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/zellij/.config/zellij/config.gbs.kdl $HOME/.config/zellij/config.kdl (if not exists / on confirmation)"
fi
