#!/bin/bash

###
# fastfetch install script
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
    install_package "fastfetch" "fastfetch --version"
    ;;
  debian|ubuntu|pop)
    if [ "$CURRENT_OS_ID" == "debian" ] && [ "$CURRENT_OS_VER" == "13" ]; then
      install_package "fastfetch" "fastfetch --version"
    else
      if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
        FF_ASSET="linux-aarch64.deb"
      else
        FF_ASSET="linux-amd64.deb"
      fi
      FF_DEB_URL="$(curl -fsSL https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r --arg asset "$FF_ASSET" '.assets[] | select(.name | contains($asset)) | .browser_download_url' | head -n 1)"
      if [[ -z "$FF_DEB_URL" || "$FF_DEB_URL" == "null" ]]; then
        cecho "red" "Failed to resolve fastfetch .deb download URL."
        return 1
      fi
      if [[ "$DRY_RUN" -ne "1" ]]; then
        FF_DEB_FILE="$(mktemp --suffix=.deb)"
        if wget -q "$FF_DEB_URL" -O "$FF_DEB_FILE" && sudo apt-get install -y "$FF_DEB_FILE"; then
          cecho "green" "[fastfetch] installation done."
        else
          cecho "red" "[fastfetch] installation failed."
        fi
        rm -f "$FF_DEB_FILE"
      else
        cecho "yellow" "DRY-RUN: wget $FF_DEB_URL -O <tmp>.deb && sudo apt-get install -y <tmp>.deb"
      fi
    fi
    ;;
  fedora|redhat)
    install_package "fastfetch" "fastfetch --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
