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
cecho "cyan" "Installing [golang]..."

if [[ ! -x "$(command -v go)" ]]; then
  cecho "yellow" -n "Please specify the version to install [1.23.1]: "
  read GOLANG_VERSION
  if [[ -z "$GOLANG_VERSION" ]]; then
    GOLANG_VERSION="1.23.1"
  fi
  if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
    GOLANG_ARCH="arm64"
  else
    GOLANG_ARCH="amd64"
  fi
  if [ "$DRY_RUN" -ne "1" ]; then
    rm -rf /usr/local/go && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz
    cecho "green" "[golang] installation done."
  else
    cecho "yellow" "DRY-RUN: rm -rf /usr/local/go && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz"
  fi
else
  cecho "yellow" "[golang] is already present."
fi

# ## OLD install script
# case $CURRENT_OS_ID in
#   arch)
#     install_package "go" "go --version"
#   ;;
#   debian|ubuntu)
#     install_package "golang" "go --version"
#   ;;
#   *)
#     cecho "red" "Unsupported OS: $CURRENT_OS_ID"
#     exit 1
#   ;;
# esac

