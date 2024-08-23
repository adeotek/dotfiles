#!/bin/bash

###
# tmux setup script
###

# Init
if [[ -d "${0%/*}" ]]; then
  SDIR=${0%/*}
else
  SDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$SDIR/_helpers.sh"
fi

# Install
. "$SDIR/tmux-install.sh"

# Setup
if [ ! -f $SDIR/../tmux/.config/tmux/tmux.conf.local ]; then
  read -p "Please select tmux local config: light/full [l/F] " tmux_local_mode
  if [[ "$tmux_local_mode" == "l" ]]; then
    tmux_local_config="gbs.light"
  else
    tmux_local_config="gbs.full"
  fi
  ln -sr $SDIR/../tmux/.config/tmux/$tmux_local_config.tmux.conf.local $SDIR/../tmux/.config/tmux/tmux.conf.local
fi

stow_package "tmux" "" "$HOME/.config/tmux"

