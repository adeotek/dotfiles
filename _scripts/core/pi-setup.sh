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

# Copy agent definitions from source to dest if the file doesn't already exist
# Usage: copy_agents_if_missing <src_dir> <dest_dir> [override]
copy_agents_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  local override="${3:-false}"
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
        cecho "green" "Agent $agent_name copied to $dest_dir/"
      else
        cecho "yellow" "Agent $agent_name already exists at $dest_dir/"
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
source "$CDIR/pi-install.sh"

# Setup
PI_AGENT_DIR="$HOME/.pi/agent"
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$PI_AGENT_DIR"
fi

PI_OVERRIDE_CONFIG=false
if [[ -f "$PI_AGENT_DIR/settings.json" ]] && [[ "${ARGS["unattended"]}" != "1" ]]; then
  read_yes_no "Pi already configured. Do you want to overwrite the existing configuration? (y/N): " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    PI_OVERRIDE_CONFIG=true
  fi
fi

# Create global settings.json file if it doesn't exist;
# on explicit override MERGE template into the existing file (template defaults
# win, live-only keys survive, arrays union) so local tweaks are not lost.
if [[ ! -f "$PI_AGENT_DIR/settings.json" ]] || [[ "$PI_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if [[ -f "$PI_AGENT_DIR/settings.json" ]]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 "$RDIR/pi/merge-pi-config.py" \
          "$RDIR/pi/settings.json" "$PI_AGENT_DIR/settings.json"; then
          cecho "green" "Merged template into existing settings.json (custom config preserved)"
        else
          cecho "red" "Failed to merge template into existing settings.json; existing config kept."
        fi
      else
        cecho "red" "python3 not found — cannot merge; existing settings.json kept, template NOT applied."
      fi
    else
      if cp "$RDIR/pi/settings.json" "$PI_AGENT_DIR/settings.json"; then
        cecho "green" "Global settings.json file created at $PI_AGENT_DIR/settings.json"
      else
        cecho "red" "Failed to create global settings.json file."
      fi
    fi
  else
    cecho "yellow" "DRY-RUN: merge or cp settings.json -> $PI_AGENT_DIR/settings.json"
  fi
else
  cecho "yellow" "Global settings.json file already exists at $PI_AGENT_DIR/settings.json"
fi

# Create global models.json file if it doesn't exist;
# on explicit override MERGE with --live-wins so a live provider apiKey (or any
# other local value) is never replaced by the template placeholder.
if [[ ! -f "$PI_AGENT_DIR/models.json" ]] || [[ "$PI_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if [[ -f "$PI_AGENT_DIR/models.json" ]]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 "$RDIR/pi/merge-pi-config.py" --live-wins \
          "$RDIR/pi/models.json" "$PI_AGENT_DIR/models.json"; then
          cecho "green" "Merged template into existing models.json (live config preserved)"
        else
          cecho "red" "Failed to merge template into existing models.json; existing config kept."
        fi
      else
        cecho "red" "python3 not found — cannot merge; existing models.json kept, template NOT applied."
      fi
    else
      if cp "$RDIR/pi/models.json" "$PI_AGENT_DIR/models.json"; then
        cecho "green" "Global models.json file created at $PI_AGENT_DIR/models.json"
      else
        cecho "red" "Failed to create global models.json file."
      fi
    fi
  else
    cecho "yellow" "DRY-RUN: merge or cp models.json -> $PI_AGENT_DIR/models.json"
  fi
else
  cecho "yellow" "Global models.json file already exists at $PI_AGENT_DIR/models.json"
fi

# Create global AGENTS.md file if it doesn't exist
if [[ ! -f "$PI_AGENT_DIR/AGENTS.md" ]] || [[ "$PI_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if cp "$RDIR/pi/AGENTS.md" "$PI_AGENT_DIR/AGENTS.md"; then
      cecho "green" "Global AGENTS.md file created at $PI_AGENT_DIR/AGENTS.md"
    else
      cecho "red" "Failed to create global AGENTS.md file."
    fi
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/pi/AGENTS.md $PI_AGENT_DIR/AGENTS.md"
  fi
else
  cecho "yellow" "Global AGENTS.md file already exists at $PI_AGENT_DIR/AGENTS.md"
fi

# Create global APPEND_SYSTEM.md file — appended instructions for Pi's system prompt
if [[ ! -f "$PI_AGENT_DIR/APPEND_SYSTEM.md" ]] || [[ "$PI_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if cp "$RDIR/pi/APPEND_SYSTEM.md" "$PI_AGENT_DIR/APPEND_SYSTEM.md"; then
      cecho "green" "Global APPEND_SYSTEM.md file created at $PI_AGENT_DIR/APPEND_SYSTEM.md"
    else
      cecho "red" "Failed to create global APPEND_SYSTEM.md file."
    fi
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/pi/APPEND_SYSTEM.md $PI_AGENT_DIR/APPEND_SYSTEM.md"
  fi
else
  cecho "yellow" "Global APPEND_SYSTEM.md file already exists at $PI_AGENT_DIR/APPEND_SYSTEM.md"
fi

# Create global pi-lens config if it doesn't exist;
# on explicit override the template replaces the live config.
PI_LENS_CONFIG_DIR="$HOME/.pi-lens"
if [[ ! -f "$PI_LENS_CONFIG_DIR/config.json" ]] || [[ "$PI_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$PI_LENS_CONFIG_DIR"
    if cp "$RDIR/pi/pi-lens-config.json" "$PI_LENS_CONFIG_DIR/config.json"; then
      cecho "green" "Global pi-lens config file created at $PI_LENS_CONFIG_DIR/config.json"
    else
      cecho "red" "Failed to create global pi-lens config file."
    fi
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/pi/pi-lens-config.json -> $PI_LENS_CONFIG_DIR/config.json (if not exists)"
  fi
else
  cecho "yellow" "Global pi-lens config file already exists at $PI_LENS_CONFIG_DIR/config.json"
fi

# Create missing skills
copy_skills_if_missing "$RDIR/pi/skills" "$PI_AGENT_DIR/skills" "$PI_OVERRIDE_CONFIG"

# Create missing subagent definitions (pi-subagents extension)
copy_agents_if_missing "$RDIR/pi/agents" "$PI_AGENT_DIR/agents" "$PI_OVERRIDE_CONFIG"

# Credential note
cecho "white" "Note: the opencode-go provider needs OPENCODE_API_KEY exported or a 'pi /login opencode-go' login."
