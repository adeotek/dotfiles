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
if [[ "$DRY_RUN" -ne "1" ]] && ! command -v rtk >/dev/null 2>&1; then
  cecho "red" "ERROR: [rtk] executable not found after install. Skipping rtk setup."
  exit 1
fi
if [[ "$DRY_RUN" -eq "1" ]] && ! command -v rtk >/dev/null 2>&1; then
  cecho "yellow" "DRY-RUN: rtk not installed — remaining rtk steps are printed only."
fi

## Disable rtk telemetry
if [[ "$DRY_RUN" -ne "1" ]]; then
  rtk telemetry disable
else
  cecho "yellow" "DRY-RUN: rtk telemetry disable"
fi

if command -v opencode &> /dev/null; then
  cecho "yellow" "Setting up rtk for opencode..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    rtk init -g --opencode
  else
    cecho "yellow" "DRY-RUN: rtk init -g --opencode"
  fi
else
  cecho "yellow" "opencode is not installed. Skipping rtk opencode setup."
fi

if command -v claude &> /dev/null; then
  cecho "yellow" "Setting up rtk for claude..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    rtk init -g --auto-patch
  else
    cecho "yellow" "DRY-RUN: rtk init -g --auto-patch"
  fi
else
  cecho "yellow" "claude is not installed. Skipping rtk claude setup."
fi

if command -v hermes &> /dev/null; then
  cecho "yellow" "Setting up rtk for hermes..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    rtk init --agent hermes
  else
    cecho "yellow" "DRY-RUN: rtk init --agent hermes"
  fi
else
  cecho "yellow" "hermes is not installed. Skipping rtk hermes setup."
fi

cecho "green" "rtk setup completed successfully."
