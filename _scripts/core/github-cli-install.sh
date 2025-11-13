#!/bin/bash

###
# GitHub CLI install script
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
  arch)
    install_package "github-cli" "gh --version" "_" "github-cli"
    ;;
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo mkdir -p -m 755 /etc/apt/keyrings
      out=$(mktemp) && wget -nv -O $out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt-get update
    fi
    install_package "gh" "gh --version"
    ;;
  fedora|redhat)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo dnf install dnf5-plugins
      sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    fi
    install_packagei "gh" "gh --version" "_" "--repo gh-cli"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

