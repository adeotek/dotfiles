#!/bin/bash

###
# Hermes Agent install script
#
# Installs Hermes Agent via the official install script.
# Hermes is an open-source AI agent framework by Nous Research.
# Homepage: https://github.com/NousResearch/hermes-agent
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi

decho "cyan" "Installing Hermes Agent..."

if [ "$DRY_RUN" -ne "1" ]; then
  if command -v hermes >/dev/null 2>&1; then
    cecho "green" "Hermes Agent already installed ($(hermes --version 2>/dev/null || echo 'unknown version')). Updating..."
    hermes update
  else
    cecho "cyan" "Installing Hermes Agent..."
    curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
    cecho "green" "Hermes Agent installed successfully."
  fi
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash"
fi
