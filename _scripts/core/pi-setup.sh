#!/bin/bash

###
# Pi coding agent setup script
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
        cp -r "$src_subdir"/. "$dest_subdir"/
        cecho "green" "Skill $skill_name copied to $dest_dir/"
      else
        cecho "yellow" "Skill $skill_name already exists at $dest_dir/"
      fi
    else
      cecho "yellow" "DRY-RUN: cp -r $src_subdir. $dest_subdir/ (if not exists)"
    fi
  done
}

# Copy prompt templates from source to dest if the file doesn't already exist
# Usage: copy_prompts_if_missing <src_dir> <dest_dir> [override] [label]
copy_prompts_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  local override="${3:-false}"
  local label="${4:-Prompt}"
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$dest_dir"
  fi
  for src_file in "$src_dir"/*.md; do
    [[ -f "$src_file" ]] || continue
    local agent_name
    agent_name=$(basename "$src_file" .md)
    local dest_file="$dest_dir/$agent_name.md"
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if [[ ! -f "$dest_file" ]] || [[ "$override" == true ]]; then
        cp "$src_file" "$dest_file"
        cecho "green" "$label $agent_name copied to $dest_dir/"
      else
        cecho "yellow" "$label $agent_name already exists at $dest_dir/"
      fi
    else
      cecho "yellow" "DRY-RUN: cp $src_file $dest_file (if not exists)"
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
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi

# Install
if ! source "$CDIR/pi-install.sh"; then
  cecho "red" "[pi] install/update failed — configuration NOT deployed."
  return 1
fi

# Setup
PI_AGENT_DIR="$HOME/.pi/agent"
PI_LENS_CONFIG_DIR="$HOME/.pi-lens"
PI_PERM_CONFIG_DIR="$PI_AGENT_DIR/extensions/pi-permission-system"
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$PI_AGENT_DIR"
fi

# Deploy a JSON config: create it when missing, merge it on an explicit override
# (a plain cp would destroy local tweaks), leave it alone otherwise.
# Usage: deploy_json_config <template> <live> [--live-wins]
deploy_json_config() {
  local tpl="$1"
  local live="$2"
  shift 2
  local name
  name=$(basename "$live")
  if [[ -f "$live" ]] && [[ "$PI_OVERRIDE_CONFIG" != true ]]; then
    cecho "yellow" "$name already exists at $live"
    return 0
  fi
  if [[ "$DRY_RUN" -eq "1" ]]; then
    cecho "yellow" "DRY-RUN: cp $tpl $live (if not exists), else merge $name"
    return 0
  fi
  mkdir -p "$(dirname "$live")"
  if [[ ! -f "$live" ]]; then
    if cp "$tpl" "$live"; then
      cecho "green" "Created $live"
    else
      cecho "red" "Failed to create $live."
    fi
    return 0
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    cecho "red" "python3 not found — cannot merge; $name kept, template NOT applied."
    return 0
  fi
  if python3 "$RDIR/pi/merge-pi-config.py" "$@" "$tpl" "$live"; then
    cecho "green" "Merged template into existing $name (live config preserved)"
  else
    cecho "red" "Failed to merge template into existing $name; existing config kept."
  fi
}

# Deploy a Markdown file: create it when missing, back up and replace it on an
# explicit override, leave it alone otherwise.
# Usage: deploy_md_file <template> <live>
deploy_md_file() {
  local tpl="$1"
  local live="$2"
  local name
  name=$(basename "$live")
  if [[ -f "$live" ]] && [[ "$PI_OVERRIDE_CONFIG" != true ]]; then
    cecho "yellow" "$name already exists at $live"
    return 0
  fi
  if [[ "$DRY_RUN" -eq "1" ]]; then
    cecho "yellow" "DRY-RUN: cp $tpl $live (if not exists; backed up when replaced)"
    return 0
  fi
  if [[ -f "$live" ]]; then
    if cp "$live" "$live.bak.$(date +%s)" && cp "$tpl" "$live"; then
      cecho "green" "Replaced $live (previous version kept as $name.bak.*)"
    else
      cecho "red" "Failed to replace $live."
    fi
    return 0
  fi
  if cp "$tpl" "$live"; then
    cecho "green" "Created $live"
  else
    cecho "red" "Failed to create $live."
  fi
}

# Any of these being present means the machine is already configured, even when
# settings.json was removed by hand.
PI_CONFIG_PRESENT=false
for pi_existing in "$PI_AGENT_DIR/settings.json" "$PI_AGENT_DIR/models.json" \
  "$PI_AGENT_DIR/AGENTS.md" "$PI_AGENT_DIR/hermes-memory-config.json" \
  "$PI_LENS_CONFIG_DIR/config.json" "$PI_PERM_CONFIG_DIR/config.json"; do
  if [[ -f "$pi_existing" ]]; then
    PI_CONFIG_PRESENT=true
  fi
done

PI_OVERRIDE_CONFIG=false
if [[ "$PI_CONFIG_PRESENT" == true ]] && [[ "${ARGS["unattended"]}" != "1" ]]; then
  read_yes_no "Pi is already configured. Refresh it from the templates? JSON configs are merged (live values kept), Markdown files are replaced with a .bak backup. (y/N): " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    PI_OVERRIDE_CONFIG=true
  fi
fi

# Global settings.json — template-wins merge keeps live-only keys and packages.
deploy_json_config "$RDIR/pi/settings.json" "$PI_AGENT_DIR/settings.json"

# Global models.json — --live-wins so a live provider apiKey is never replaced by
# the template placeholder.
deploy_json_config "$RDIR/pi/models.json" "$PI_AGENT_DIR/models.json" --live-wins

# Global AGENTS.md — instructions for every pi session.
deploy_md_file "$RDIR/pi/AGENTS.md" "$PI_AGENT_DIR/AGENTS.md"

# Global APPEND_SYSTEM.md — appended to Pi's system prompt.
deploy_md_file "$RDIR/pi/APPEND_SYSTEM.md" "$PI_AGENT_DIR/APPEND_SYSTEM.md"

# Global pi-lens config.
deploy_json_config "$RDIR/pi/pi-lens-config.json" "$PI_LENS_CONFIG_DIR/config.json"

# Global pi-permission-system config.
deploy_json_config "$RDIR/pi/pi-permission-system.config.json" "$PI_PERM_CONFIG_DIR/config.json"

# Global pi-hermes-memory config.
deploy_json_config "$RDIR/pi/hermes-memory-config.json" "$PI_AGENT_DIR/hermes-memory-config.json"

# Create missing skills
copy_skills_if_missing "$RDIR/pi/skills" "$PI_AGENT_DIR/skills" "$PI_OVERRIDE_CONFIG"

# Create missing prompt templates (flat .md files)
copy_prompts_if_missing "$RDIR/pi/prompts" "$PI_AGENT_DIR/prompts" "$PI_OVERRIDE_CONFIG" "Prompt"

# Credential note
cecho "white" "Note: the opencode-go provider needs OPENCODE_API_KEY exported or a 'pi /login opencode-go' login."
