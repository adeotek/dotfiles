#!/bin/bash

###
# tmux setup script
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
source "$CDIR/tmux-install.sh"

# Setup
tmux_conf_local="$CDIR/../../tmux/.config/tmux/tmux.conf.local"
if [[ -L "$tmux_conf_local" && ! -e "$tmux_conf_local" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    rm -f "$tmux_conf_local"
    cecho "yellow" "Removed dangling tmux.conf.local symlink — recreating it."
  else
    cecho "yellow" "DRY-RUN: rm -f $tmux_conf_local (dangling symlink)"
  fi
fi
if [[ ! -e "$tmux_conf_local" ]]; then
  tmux_local_config="gbs.full"
  if [[ "${ARGS["unattended"]}" != "1" ]]; then
    read -r -p "Please select tmux local config: light/full [l/F] " tmux_local_mode || tmux_local_mode=""
    if [[ "$tmux_local_mode" == "l" ]]; then
      tmux_local_config="gbs.light"
    fi
  fi
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if ! ln -sr "$CDIR/../../tmux/.config/tmux/$tmux_local_config.tmux.conf.local" "$CDIR/../../tmux/.config/tmux/tmux.conf.local"; then
      cecho "red" "Failed to create tmux.conf.local link."
    fi
  else
    cecho "yellow" "DRY-RUN: ln -sr .../tmux/$tmux_local_config.tmux.conf.local .../tmux/tmux.conf.local"
  fi
fi

stow_package "tmux" "" "$CURRENT_CONFIG_DIR/tmux"
