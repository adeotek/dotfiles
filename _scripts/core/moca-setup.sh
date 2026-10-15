#!/bin/bash

###
# moca coding agent setup script
#
# Deploys the moca configuration to <config dir>/moca/:
# - config.jsonc with the default model/provider/limits setup
# - AGENTS.md with global instructions for every session (seeded only if missing)
# - prompts/ with saved slash-command templates (code review, debugging,
#   documenting code)
# - skills/ with agent skills (seeded only if missing)
# Follows the same pattern as opencode-setup.sh / pi-setup.sh: files are
# copied, not stowed, and an existing config is never clobbered — on an
# explicit override it is MERGED so the model saved by /model, a personal
# shell allowlist and extra providers survive.
###

# Copy skill subdirectories from source to dest if SKILL.md doesn't already exist
# Usage: copy_skills_if_missing <src_dir> <dest_dir> [override]
copy_skills_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  local override="${3:-false}"
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$dest_dir"
  fi
  for src_subdir in "$src_dir"/*/; do
    [[ -d "$src_subdir" ]] || continue
    local skill_name
    skill_name=$(basename "$src_subdir")
    local dest_subdir="$dest_dir/$skill_name"
    if [[ "$DRY_RUN" -ne "1" ]]; then
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
source "$CDIR/moca-install.sh"

# Setup
# moca honours $XDG_CONFIG_HOME (falling back to ~/.config); deploy where it
# actually reads the config from.
MOCA_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/moca"
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$MOCA_CONFIG_DIR"
fi

MOCA_OVERRIDE_CONFIG=false
if [[ -f "$MOCA_CONFIG_DIR/config.jsonc" ]] && [[ "${ARGS["unattended"]}" != "1" ]]; then
  read_yes_no "moca already configured. Do you want to overwrite the existing configuration? (y/N): " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    MOCA_OVERRIDE_CONFIG=true
  fi
fi

# Create global config.jsonc file if it doesn't exist;
# on explicit override MERGE the template into the existing config with
# --live-wins (the live file wins, the template only fills in missing keys and
# never appends array entries) so the model chosen with /model, a custom shell
# allowlist and extra providers are never reset to the template defaults.
if [[ ! -f "$MOCA_CONFIG_DIR/config.jsonc" ]] || [[ "$MOCA_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if [[ -f "$MOCA_CONFIG_DIR/config.jsonc" ]]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 "$RDIR/moca/merge-moca-config.py" --live-wins \
          "$RDIR/moca/config.jsonc" "$MOCA_CONFIG_DIR/config.jsonc"; then
          cecho "green" "Merged template into existing config.jsonc (live config preserved)"
        else
          cecho "red" "Failed to merge template into existing config.jsonc; existing config kept."
        fi
      else
        cecho "red" "python3 not found — cannot merge; existing config.jsonc kept, template NOT applied."
      fi
    else
      if cp "$RDIR/moca/config.jsonc" "$MOCA_CONFIG_DIR/config.jsonc"; then
        cecho "green" "Global config.jsonc file created at $MOCA_CONFIG_DIR/config.jsonc"
      else
        cecho "red" "Failed to create global config.jsonc file."
      fi
    fi
  else
    cecho "yellow" "DRY-RUN: merge or cp moca/config.jsonc -> $MOCA_CONFIG_DIR/config.jsonc"
  fi
else
  cecho "yellow" "Global config.jsonc file already exists at $MOCA_CONFIG_DIR/config.jsonc"
fi

# Create the global AGENTS.md file if it doesn't exist — global instructions
# loaded into every session. The user's own file is never overwritten.
copy_files_if_missing "$RDIR/moca" "$MOCA_CONFIG_DIR" "AGENTS.md"

# Create missing slash-command prompt templates (a template that already
# exists is the user's from then on, like the moca-seeded /create-command)
copy_files_if_missing "$RDIR/moca/prompts" "$MOCA_CONFIG_DIR/prompts" "*.md" "$MOCA_OVERRIDE_CONFIG"

# Create missing skills (a skill that already exists is the user's from then on;
# on explicit override the template replaces it)
copy_skills_if_missing "$RDIR/moca/skills" "$MOCA_CONFIG_DIR/skills" "$MOCA_OVERRIDE_CONFIG"
