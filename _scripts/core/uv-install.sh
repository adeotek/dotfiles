#!/bin/bash

###
# uv (Python package manager) install script
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
cecho "cyan" "Installing [uv]..."

if command -v uv >/dev/null 2>&1; then
  cecho "yellow" "[uv] is already present."
else
  if [ "$DRY_RUN" -ne "1" ]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    cecho "green" "[uv] installation done."
  else
    cecho "yellow" "DRY-RUN: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
fi
