#!/bin/bash

###
# zsh setup script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["prompt"]=""
else
  declare -A ARGS=(["prompt"]="")
fi
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi
process_args $@

# Install
source "$CDIR/zsh-install.sh"

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "zsh" "" "$CURRENT_CONFIG_DIR/zsh"

# Enable custom config
if ! grep -q "source $CURRENT_CONFIG_DIR/zsh/config.zsh" "$HOME/.zshrc"; then
  (echo; echo "source $CURRENT_CONFIG_DIR/zsh/config.zsh") >> "$HOME/.zshrc"
fi

