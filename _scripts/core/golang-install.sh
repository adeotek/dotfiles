#!/bin/bash

###
# Go Lang install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["version"]=""
else
  declare -A ARGS=(["version"]="")
fi
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
if [[ -z "${ARGS["version"]}" ]]; then
  cecho "yellow" -n "Please specify the version to install [1.23.1]: "
  read DOTNET_VERSION
  if [[ -z "$GOLANG_VERSION" ]]; then
    GOLANG_VERSION="1.23.1"
  fi
else
  GOLANG_VERSION="${ARGS["version"]}"
fi

if [[ -z "$GOLANG_VERSION" ]]; then
  cecho "red" "No GoLang version provided. Skipping..."
else
  GOLANG_INSTALLED=""
  if [[ -x "$(command -v gog)" ]]; then
    if go version | grep "$GOLANG_VERSION" > /dev/null; then
      cecho "yellow" "[golang] is already present."
      GOLANG_INSTALLED="1"
    else
      cecho "cyan" "Upgrading [golang]..."
    fi
  else
    cecho "cyan" "Installing [golang]..."
  fi

  if [[ -z "$GOLANG_INSTALLED" ]]; then
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      GOLANG_ARCH="arm64"
    else
      GOLANG_ARCH="amd64"
    fi
    if [ "$DRY_RUN" -ne "1" ]; then
      wget https://go.dev/dl/go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz
      rm -rf /usr/local/go && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz
      rm -f go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz
      cecho "green" "[golang] installation done."
    else
      cecho "yellow" "DRY-RUN: rm -rf /usr/local/go && tar -C /usr/local -xzf go$GOLANG_VERSION.linux-${GOLANG_ARCH}.tar.gz"
    fi
  fi
fi
