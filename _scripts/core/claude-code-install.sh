#!/bin/bash

###
# Claude Code install script (native mode)
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
cecho "cyan" "Installing [claude-code]..."

# Check if already installed
if command -v claude >/dev/null 2>&1; then
  cecho "yellow" "[claude-code] is already present. Upgrading to the latest version..."
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  if ! (set -o pipefail; curl -fsSL https://claude.ai/install.sh | bash); then
    cecho "red" "[claude-code] installation failed."
    return 1
  fi
  cecho "green" "[claude-code] installation done."
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://claude.ai/install.sh | bash"
fi
