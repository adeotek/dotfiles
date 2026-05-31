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
# Create global opencode.jsonc file if it doesn't exist
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/opencode/opencode.jsonc" ]; then
    cp "$RDIR/opencode/opencode.jsonc.sample" "$HOME/.config/opencode/opencode.jsonc"
    cecho "green" "Global opencode.jsonc file created at ~/.config/opencode/opencode.jsonc"
  else
    cecho "yellow" "Global opencode.jsonc file already exists at ~/.config/opencode/opencode.jsonc"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/opencode/opencode.jsonc.sample $HOME/.config/opencode/opencode.jsonc"
fi

# Create global AGENTS.md file if it doesn't exist
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/opencode/AGENTS.md" ]; then
    cp "$RDIR/opencode/AGENTS.md.sample" "$HOME/.config/opencode/AGENTS.md"
    cecho "green" "Global AGENTS.md file created at ~/.config/opencode/AGENTS.md"
  else
    cecho "yellow" "Global AGENTS.md file already exists at ~/.config/opencode/AGENTS.md"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/opencode/AGENTS.md.sample $HOME/.config/opencode/AGENTS.md"
fi

# Create missing skills/plugins/agents
if [ "$DRY_RUN" -ne "1" ]; then
  mkdir -p "$HOME/.config/opencode/{skills,plugins,agents}"
  # TODO
else
  cecho "yellow" "DRY-RUN: mkdir -p $HOME/.config/opencode/{skills,plugins,agents}"
fi
