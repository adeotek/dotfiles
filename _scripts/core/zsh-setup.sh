#!/bin/bash

###
# zsh setup script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" == "1" ]]; then
    ARGS["prompt"]="$OPT_ZSH_DEFAULT_PROMPT"
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

# Install
source "$CDIR/zsh-install.sh"

# Setup
if [[ "${ARGS["prompt"]}" == "oh-my-posh" ]]; then
  source "$CDIR/oh-my-posh-setup.sh"
fi
if [[ "${ARGS["prompt"]}" == "starship" ]]; then
  source "$CDIR/starship-setup.sh"
fi

stow_package "zsh" "" "$CURRENT_CONFIG_DIR/zsh"

# Record the chosen prompt tool so config.zsh can honor it (per-machine file)
if [[ -n "${ARGS["prompt"]}" ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$CURRENT_CONFIG_DIR/zsh"
    echo "${ARGS["prompt"]}" > "$CURRENT_CONFIG_DIR/zsh/prompt-tool"
  else
    cecho "yellow" "DRY-RUN: echo ${ARGS["prompt"]} > $CURRENT_CONFIG_DIR/zsh/prompt-tool"
  fi
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  # Enable custom config
  if [[ -f "$HOME/.zshrc" ]]; then
    if ! grep -qF "source $CURRENT_CONFIG_DIR/zsh/config.zsh" "$HOME/.zshrc"; then
      (echo; echo "source $CURRENT_CONFIG_DIR/zsh/config.zsh") >> "$HOME/.zshrc"
    fi
  else
    echo "source $CURRENT_CONFIG_DIR/zsh/config.zsh" > "$HOME/.zshrc"
  fi
else
  cecho "yellow" "DRY-RUN: ensure 'source $CURRENT_CONFIG_DIR/zsh/config.zsh' in ~/.zshrc"
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  # Change default shell to zsh
  if [[ "$(basename "$SHELL")" != "zsh" ]]; then
    echo "Changing default shell to zsh..."
  fi
  chsh -s "$(which zsh)"
else
  cecho "yellow" "DRY-RUN: chsh -s \"$(which zsh)\""
fi
