#!/bin/bash

###
# Go Lang install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["version"]="$OPT_GOLANG_DEFAULT_VERSION"
  else
    ARGS["version"]=""
  fi
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
  cecho "yellow" -n "Please specify the GoLang version to install [$OPT_GOLANG_DEFAULT_VERSION]: "
  read -r GOLANG_VERSION
  if [[ -z "$GOLANG_VERSION" ]]; then
    GOLANG_VERSION="$OPT_GOLANG_DEFAULT_VERSION"
  fi
else
  GOLANG_VERSION="${ARGS["version"]}"
fi

if [[ -z "$GOLANG_VERSION" ]]; then
  cecho "red" "No GoLang version provided. Skipping..."
else
  GOLANG_INSTALLED=""
  if [[ -x "$(command -v go)" ]]; then
    if go version | grep -q "go${GOLANG_VERSION} "; then
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
    GOLANG_URL="https://go.dev/dl/go${GOLANG_VERSION}.linux-${GOLANG_ARCH}.tar.gz"
    if [[ "$DRY_RUN" -ne "1" ]]; then
      GOLANG_TARBALL="$(mktemp)"
      if ! wget -q "$GOLANG_URL" -O "$GOLANG_TARBALL"; then
        cecho "red" "Failed to download Go ${GOLANG_VERSION}. Existing [golang] install left untouched."
        rm -f "$GOLANG_TARBALL"
        return 1
      fi
      if sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "$GOLANG_TARBALL"; then
        cecho "green" "[golang] installation done."
      else
        cecho "red" "[golang] extraction into /usr/local/go failed."
      fi
      rm -f "$GOLANG_TARBALL"
    else
      cecho "yellow" "DRY-RUN: wget $GOLANG_URL -O <tmp> && sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf <tmp>"
    fi
  fi
fi
