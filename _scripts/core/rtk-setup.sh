#!/bin/bash

###
# rtk setup script
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
source "$CDIR/rtk-install.sh"

# Setup
## Disable rtk telemetry
rtk telemetry disable

if command -v opencode &> /dev/null; then
  cecho "yellow" "Setting up rtk for opencode..."
  rtk init -g --opencode
else
  cecho "yellow" "opencode is not installed. Skipping rtk opencode setup."
fi

if command -v claude &> /dev/null; then
  cecho "yellow" "Setting up rtk for claude..."
  rtk init -g --auto-patch
else
  cecho "yellow" "claude is not installed. Skipping rtk claude setup."
fi

if command -v hermes &> /dev/null; then
  cecho "yellow" "Setting up rtk for hermes..."
  rtk init --agent hermes
else
  cecho "yellow" "hermes is not installed. Skipping rtk hermes setup."
fi

cecho "green" "rtk setup completed successfully."
