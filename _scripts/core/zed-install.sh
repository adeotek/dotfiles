#!/bin/bash

###
# Zed install script
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
case $CURRENT_OS_ID in
  arch|debian|ubuntu|pop|fedora|redhat)
    cecho "cyan" "Installing [zed]..."
    if command -v zed >/dev/null 2>&1; then
      decho "yellow" "Package already installed. Updating it..."
    fi

    if [[ "$DRY_RUN" -ne "1" ]]; then
      decho "magenta" "curl -fsSL https://zed.dev/install.sh | sh"
      if ! (set -o pipefail; curl -fsSL https://zed.dev/install.sh | sh); then
        cecho "red" "[zed] installation failed."
        return 1
      fi
      cecho "green" "[zed] installation done."
    else
      cecho "yellow" "DRY-RUN: curl -fsSL https://zed.dev/install.sh | sh"
    fi
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
