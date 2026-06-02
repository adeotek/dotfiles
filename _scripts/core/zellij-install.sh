#!/bin/bash

###
# zellij install script
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
    install_package "zellij" "zellij --version"
    ;;
  debian|ubuntu|pop)
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      source "$CDIR/rustup-install.sh"
      cecho "cyan" "Installing [zellij]..."
      if [ "$DRY_RUN" -ne "1" ]; then
        cargo install --locked zellij
        cecho "green" "[zellij] installation done."
      else
        cecho "yellow" "DRY-RUN: cargo install --locked zellij"
      fi
    else
      source "$CDIR/homebrew-install.sh"
      install_package "zellij" "zellij --version" "brew install zellij"
    fi
    ;;
  fedora|redhat)
    source "$CDIR/homebrew-install.sh"
    install_package "zellij" "zellij --version" "brew install zellij"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac
