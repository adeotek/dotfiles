#!/bin/bash

###
# tmux install script
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
install_package "tmux" "tmux -V"

# Install tmux-256color terminfo (needed for correct key sequences over SSH)
case $CURRENT_OS_ID in
  debian|ubuntu|pop)
    install_package "ncurses-term" "infocmp tmux-256color"
    ;;
  arch|fedora|redhat)
    install_package "ncurses" "infocmp tmux-256color"
    ;;
esac
