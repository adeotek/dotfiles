#!/bin/bash

###
# Hermes Agent setup script
#
# Deploys Hermes configuration files to ~/.hermes/.
# Follows the same pattern as claude-code and opencode:
# - Copies config.yaml if it doesn't exist (first-time setup)
# - Otherwise, uses hermes config check to report status
# - Does NOT overwrite existing config to preserve local changes
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

# Install Hermes Agent first
source "$CDIR/hermes-install.sh"

# Setup config.yaml
if [ "$DRY_RUN" -ne "1" ]; then
  mkdir -p "$HOME/.hermes"
  if [ ! -f "$HOME/.hermes/config.yaml" ]; then
    cp "$RDIR/hermes/config.yaml" "$HOME/.hermes/config.yaml"
    cecho "green" "Hermes config.yaml deployed to ~/.hermes/config.yaml"
    cecho "cyan" "Next: add your API keys to ~/.hermes/.env and run 'hermes setup'"
  else
    cecho "yellow" "Hermes config.yaml already exists — skipping. To update, compare with:"
    cecho "cyan" "  diff $RDIR/hermes/config.yaml $HOME/.hermes/config.yaml"
    if command -v hermes >/dev/null 2>&1; then
      hermes config check
    fi
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/config.yaml $HOME/.hermes/config.yaml (if not exists)"
fi

# Create .env template if missing
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.hermes/.env" ]; then
    cp "$RDIR/hermes/.env.template" "$HOME/.hermes/.env"
    cecho "green" "Hermes .env template created at ~/.hermes/.env"
  else
    cecho "yellow" "Hermes .env already exists — skipping"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/.env.template $HOME/.hermes/.env (if not exists)"
fi
