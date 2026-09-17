#!/bin/bash

###
# bash setup script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" == "1" ]]; then
    ARGS["prompt"]="$OPT_BASH_DEFAULT_PROMPT"
  else
    ARGS["prompt"]=""
  fi
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

process_args "$@"

# Setup
if [[ "${ARGS["prompt"]}" == "oh-my-posh" ]]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [[ "${ARGS["prompt"]}" == "starship" ]]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "bash" "" "$CURRENT_CONFIG_DIR/bash"

# Record the chosen prompt tool so config.bash can honor it (per-machine file)
if [[ -n "${ARGS["prompt"]}" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$CURRENT_CONFIG_DIR/bash"
    echo "${ARGS["prompt"]}" > "$CURRENT_CONFIG_DIR/bash/prompt-tool"
  else
    cecho "yellow" "DRY-RUN: echo ${ARGS["prompt"]} > $CURRENT_CONFIG_DIR/bash/prompt-tool"
  fi
fi

# Enable custom config
if [[ "$DRY_RUN" -ne "1" ]]; then
  if ! grep -qF "source $CURRENT_CONFIG_DIR/bash/config.bash" "$HOME/.bashrc"; then
    (echo; echo "source $CURRENT_CONFIG_DIR/bash/config.bash") >> "$HOME/.bashrc"
  fi
else
  cecho "yellow" "DRY-RUN: ensure 'source $CURRENT_CONFIG_DIR/bash/config.bash' in ~/.bashrc"
fi
