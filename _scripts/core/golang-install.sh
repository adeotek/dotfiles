#!/bin/bash

###
# Go Lang install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
case $CURRENT_OS_ID in
  arch)
    install_package "go" "go --version"
  ;;
  debian|ubuntu)
    install_package "golang" "go --version"
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
