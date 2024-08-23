#!/bin/bash

###
# tmux setup script
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
. "$CDIR/tmux-install.sh"

# Setup
if [ ! -f $CDIR/../tmux/.config/tmux/tmux.conf.local ]; then
  read -p "Please select tmux local config: light/full [l/F] " tmux_local_mode
  if [[ "$tmux_local_mode" == "l" ]]; then
    tmux_local_config="gbs.light"
  else
    tmux_local_config="gbs.full"
  fi
  ln -sr $CDIR/../tmux/.config/tmux/$tmux_local_config.tmux.conf.local $CDIR/../tmux/.config/tmux/tmux.conf.local
fi

stow_package "tmux" "" "$HOME/.config/tmux"

