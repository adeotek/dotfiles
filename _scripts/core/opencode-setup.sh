#!/bin/bash

###
# OpenCode setup script
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
source "$CDIR/opencode-install.sh"

# Setup (stow only the opencode.jsonc file)
stow_file "opencode" "opencode.jsonc"
# TODO: stow skills configs
#stow_package "opencode/skills" "" "$CURRENT_CONFIG_DIR/opencode/skills"
