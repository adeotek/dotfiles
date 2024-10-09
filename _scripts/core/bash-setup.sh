#!/bin/bash

###
# bash setup script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["prompt"]=""
else
  declare -A ARGS=(["prompt"]="")
fi
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

process_args $@

# Setup
if [ "${ARGS["prompt"]}" == "oh-my-posh" ]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [ "${ARGS["prompt"]}" == "starship" ]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "bash" "" "$CURRENT_CONFIG_DIR/bash"

# Enable custom config
if ! grep -q 'source $CURRENT_CONFIG_DIR/bash/config.bash' "$HOME/.bashrc"; then
  (echo; echo 'source $CURRENT_CONFIG_DIR/bash/config.bash') >> "$HOME/.bashrc"
fi

