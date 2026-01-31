#!/bin/bash

###
# OpenCode install script
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
cecho "cyan" "Installing [opencode]..."

# Check if already installed
if command -v opencode >/dev/null 2>&1; then
  cecho "yellow" "[opencode] is already present."
else
  if [ "$DRY_RUN" -ne "1" ]; then
    curl -fsSL https://opencode.ai/install | bash
  else
    cecho "yellow" "DRY-RUN: curl -fsSL https://opencode.ai/install | bash"
  fi
fi
