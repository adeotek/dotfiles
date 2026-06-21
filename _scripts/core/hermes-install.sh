#!/bin/bash

###
# Hermes Agent install script
# Installs Hermes Agent (Nous Research) via the official curl installer
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
cecho "cyan" "Installing [hermes]..."

# Check if already installed
if command -v hermes >/dev/null 2>&1; then
  cecho "yellow" "[hermes] is already present. Updating it..."
  if [ "$DRY_RUN" -ne "1" ]; then
    hermes update
    cecho "green" "[hermes] update done."
  else
    cecho "yellow" "DRY-RUN: hermes update"
  fi
else
  if [ "$DRY_RUN" -ne "1" ]; then
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
    cecho "green" "[hermes] installation done."
  else
    cecho "yellow" "DRY-RUN: curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
  fi
fi

# Verify
if [ "$DRY_RUN" -ne "1" ]; then
  if command -v hermes >/dev/null 2>&1; then
    cecho "green" "[hermes] $(hermes --version 2>/dev/null || echo 'installed') successfully."
  else
    cecho "red" "[hermes] installation failed — 'hermes' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: hermes --version"
fi
