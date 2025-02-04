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
  arch)
    if [ flatpak --version >/dev/null 2>&1 ]; then
      install_package "zed" "zed --version" "flatpak install -y dev.zed.Zed"
    else
      install_package "zed" "zed --version"
    fi
  ;;
  debian|ubuntu)
    cecho "cyan" "Installing [zed]..."
    if [ zed --version >/dev/null 2>&1 ]; then
      decho "yellow" "Package already installed. Updating it..."
    fi

    if [ "$DRY_RUN" -ne "1" ]; then
      decho "magenta" "curl -f https://zed.dev/install.sh | sh"
      curl -f https://zed.dev/install.sh | sh
      cecho "green" "[kitty] installation done."
    else
      cecho "yellow" "DRY-RUN: curl -f https://zed.dev/install.sh | sh"
    fi
  ;;
  pop)
    if [ flatpak --version >/dev/null 2>&1 ]; then
      install_package "zed" "zed --version" "flatpak install -y dev.zed.Zed"
    else
      install_package "zed" "zed --version"
    fi
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac

