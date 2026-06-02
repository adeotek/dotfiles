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
    cp "$RDIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"
    cecho "green" "Global opencode.jsonc file created at ~/.config/opencode/opencode.jsonc"
  else
    cecho "yellow" "Global opencode.jsonc file already exists at ~/.config/opencode/opencode.jsonc"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/opencode/opencode.jsonc $HOME/.config/opencode/opencode.jsonc"
fi

# Create global tui.json file if it doesn't exist
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/opencode/tui.json" ]; then
    cp "$RDIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"
    cecho "green" "Global tui.json file created at ~/.config/opencode/tui.json"
  else
    cecho "yellow" "Global tui.json file already exists at ~/.config/opencode/tui.json"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/opencode/tui.json $HOME/.config/opencode/tui.json"
fi

# Create global AGENTS.md file if it doesn't exist
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/opencode/AGENTS.md" ]; then
    cp "$RDIR/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
    cecho "green" "Global AGENTS.md file created at ~/.config/opencode/AGENTS.md"
  else
    cecho "yellow" "Global AGENTS.md file already exists at ~/.config/opencode/AGENTS.md"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/opencode/AGENTS.md $HOME/.config/opencode/AGENTS.md"
fi

# Copy skill subdirectories from source to dest if SKILL.md doesn't already exist
# Usage: copy_skills_if_missing <src_dir> <dest_dir>
copy_skills_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  if [ "$DRY_RUN" -ne "1" ]; then
    mkdir -p "$dest_dir"
  fi
  for src_subdir in "$src_dir"/*/; do
    [[ -d "$src_subdir" ]] || continue
    local skill_name
    skill_name=$(basename "$src_subdir")
    local dest_subdir="$dest_dir/$skill_name"
    if [ "$DRY_RUN" -ne "1" ]; then
      if [[ ! -f "$dest_subdir/SKILL.md" ]]; then
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

# Create missing skills/plugins/agents
copy_files_if_missing "$RDIR/opencode/agents"  "$HOME/.config/opencode/agents"  "*.md"
copy_files_if_missing "$RDIR/opencode/plugins" "$HOME/.config/opencode/plugins" "*.js"
copy_skills_if_missing  "$RDIR/opencode/skills" "$HOME/.config/opencode/skills"
