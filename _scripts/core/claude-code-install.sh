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
  cecho "yellow" "[claude-code] is already present."
else
  if [ "$DRY_RUN" -ne "1" ]; then
    curl -fsSL https://claude.ai/install.sh | bash
  else
    cecho "yellow" "DRY-RUN: curl -fsSL https://claude.ai/install.sh | bash"
  fi
fi
