#!/bin/bash

###
# helm install script
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
if ! command -v helm &> /dev/null; then
  cecho "cyan" "Installing Helm via get-helm-3 script..."
  if [ "$DRY_RUN" -ne "1" ]; then
    decho "magenta" "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  else
    cecho "yellow" "DRY-RUN: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
  fi
fi
