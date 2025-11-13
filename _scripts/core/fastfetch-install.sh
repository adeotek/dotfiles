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
  debian|ubuntu|pop)
    if [ "$CURRENT_OS_ID" == "debian" ] && [ "$CURRENT_OS_VER" == "13" ]; then
      install_package "fastfetch" "fastfetch --version"
    else
      if [ "$CURRENT_ARCH" == "aarch64" ]; then
        FF_DEB_URL="$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r '.assets[] | select(.name | contains("linux-aarch64.deb")) | .browser_download_url')"
      else
        FF_DEB_URL="$(curl -s https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64.deb")) | .browser_download_url')"
      fi
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget $FF_DEB_URL -O /tmp/fastfetch.deb"
        wget "$FF_DEB_URL" -O /tmp/fastfetch.deb
        decho "magenta" "sudo apt-get install /tmp/fastfetch.deb -y"
        sudo apt-get install /tmp/fastfetch.deb -y
        decho "magenta" "rm -f /tmp/fastfetch.deb"
        rm -f /tmp/fastfetch.deb
      else
        cecho "yellow" "DRY-RUN: wget $FF_DEB_URL -O /tmp/fastfetch.deb"
        cecho "yellow" "DRY-RUN: sudo apt-get install /tmp/fastfetch.deb -y"
        cecho "yellow" "DRY-RUN: rm -f /tmp/fastfetch.deb"
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

