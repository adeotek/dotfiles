#!/bin/bash

###
# onefetch install script
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
    install_package "onefetch" "onefetch --version"
    ;;
  debian|ubuntu|pop)
    source "$CDIR/homebrew-install.sh"
    install_package "onefetch" "onefetch --version" "brew install onefetch"
    ;;
  fedora|redhat|centos|almalinux)
    source "$CDIR/homebrew-install.sh"
    install_package "onefetch" "onefetch --version" "brew install onefetch"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac
