#!/bin/bash

###
# OpenCode setup script
###

# Copy skill subdirectories from source to dest if SKILL.md doesn't already exist
# Usage: copy_skills_if_missing <src_dir> <dest_dir> [override]
copy_skills_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  local override="${3:-false}"
  if [ "$DRY_RUN" -ne "1" ]; then
    mkdir -p "$dest_dir"
  fi
  for src_subdir in "$src_dir"/*/; do
    [[ -d "$src_subdir" ]] || continue
    local skill_name
    skill_name=$(basename "$src_subdir")
    local dest_subdir="$dest_dir/$skill_name"
    if [ "$DRY_RUN" -ne "1" ]; then
      if [[ ! -f "$dest_subdir/SKILL.md" ]] || [[ "$override" == true ]]; then
        mkdir -p "$dest_subdir"
        cp -r "$src_subdir"* "$dest_subdir/"
        cecho "green" "Skill $skill_name copied to $dest_dir/"
      else
        cecho "yellow" "Skill $skill_name already exists at $dest_dir/"
      fi
    else
      cecho "yellow" "DRY-RUN: cp -r $src_subdir $dest_subdir/ (if not exists)"
    fi
  done
}

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
mkdir -p "$HOME/.config/opencode"
OC_OVERRIDE_CONFIG=false
if [[ -f "$HOME/.config/opencode/opencode.jsonc" ]] && [[ "${ARGS["unattended"]}" != "1" ]]; then
  cecho "yellow" -n "OpenCode already configured. Do you want to overwrite the existing configuration? (y/N): "
  read -r OC_OVERRIDE_RESPONSE
  if [[ "$OC_OVERRIDE_RESPONSE" =~ ^[Yy]$ ]]; then
    OC_OVERRIDE_CONFIG=true
  fi
fi

# Create global opencode.jsonc file if it doesn't exist
if [[ ! -f "$HOME/.config/opencode/opencode.jsonc" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [ "$DRY_RUN" -ne "1" ]; then
    cp "$RDIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    cecho "green" "Global opencode.jsonc file created at ~/.config/opencode/opencode.jsonc"
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/opencode/opencode.jsonc $HOME/.config/opencode/opencode.jsonc"
  fi
else
  cecho "yellow" "Global opencode.jsonc file already exists at ~/.config/opencode/opencode.jsonc"
fi

# Create global tui.json file if it doesn't exist
if [[ ! -f "$HOME/.config/opencode/tui.json" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [ "$DRY_RUN" -ne "1" ]; then
    cp "$RDIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"
    cecho "green" "Global tui.json file created at ~/.config/opencode/tui.json"
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/opencode/tui.json $HOME/.config/opencode/tui.json"
  fi
else
  cecho "yellow" "Global tui.json file already exists at ~/.config/opencode/tui.json"
fi

# Create global AGENTS.md file if it doesn't exist
if [[ ! -f "$HOME/.config/opencode/AGENTS.md" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [ "$DRY_RUN" -ne "1" ]; then
    cp "$RDIR/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
    cecho "green" "Global AGENTS.md file created at ~/.config/opencode/AGENTS.md"
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/opencode/AGENTS.md $HOME/.config/opencode/AGENTS.md"
  fi
else
  cecho "yellow" "Global AGENTS.md file already exists at ~/.config/opencode/AGENTS.md"
fi

# Create missing skills/plugins/agents
copy_files_if_missing "$RDIR/opencode/agents"  "$HOME/.config/opencode/agents"  "*.md" "$OC_OVERRIDE_CONFIG"
copy_files_if_missing "$RDIR/opencode/plugins" "$HOME/.config/opencode/plugins" "*.js" "$OC_OVERRIDE_CONFIG"
copy_skills_if_missing  "$RDIR/opencode/skills" "$HOME/.config/opencode/skills" "$OC_OVERRIDE_CONFIG"
