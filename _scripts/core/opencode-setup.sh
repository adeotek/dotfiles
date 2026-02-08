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

# Setup 
## stow only the opencode.jsonc file
symlink_package_file "opencode" "opencode.jsonc"
## stow agents config directory
symlink_package_directory "opencode" "agents" "" "$CURRENT_CONFIG_DIR/opencode/agents"
## stow skills config directory
symlink_package_directory "opencode" "skills" "" "$CURRENT_CONFIG_DIR/opencode/skills"
