#!/bin/bash

###
# Kitty install script
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
    install_package "kitty" "kitty --version"
  ;;
  debian|ubuntu|pop)
    cecho "cyan" "Installing [kitty]..."
    if [ kitty --version >/dev/null 2>&1 ]; then
      decho "yellow" "Package already installed. Updating it..."
    fi

    if [ "$DRY_RUN" -ne "1" ]; then
      decho "magenta" "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
      curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
      cecho "green" "[kitty] installation done."
    else
      cecho "yellow" "DRY-RUN: curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
    fi
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
