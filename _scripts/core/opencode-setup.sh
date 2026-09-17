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
source "$CDIR/opencode-install.sh"

# Setup
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$HOME/.config/opencode"
fi
OC_OVERRIDE_CONFIG=false
if [[ -f "$HOME/.config/opencode/opencode.jsonc" ]] && [[ "${ARGS["unattended"]}" != "1" ]]; then
  read_yes_no "OpenCode already configured. Do you want to overwrite the existing configuration? (y/N): " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    OC_OVERRIDE_CONFIG=true
  fi
fi

# Create global opencode.jsonc file if it doesn't exist;
# on explicit override MERGE template into the existing config so custom
# plugins/provider options/credentials are never lost (plain cp clobbers them).
if [[ ! -f "$HOME/.config/opencode/opencode.jsonc" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if [[ -f "$HOME/.config/opencode/opencode.jsonc" ]]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 "$RDIR/opencode/merge-opencode-config.py" \
          "$RDIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"; then
          cecho "green" "Merged template into existing opencode.jsonc (custom config preserved)"
        else
          cecho "red" "Failed to merge template into existing opencode.jsonc; existing config kept."
        fi
      else
        cecho "red" "python3 not found — cannot merge; existing opencode.jsonc kept, template NOT applied."
      fi
    else
      if cp "$RDIR/opencode/opencode.jsonc" "$HOME/.config/opencode/opencode.jsonc"; then
        cecho "green" "Global opencode.jsonc file created at ~/.config/opencode/opencode.jsonc"
      else
        cecho "red" "Failed to create global opencode.jsonc file."
      fi
    fi
  else
    cecho "yellow" "DRY-RUN: merge or cp opencode.jsonc -> $HOME/.config/opencode/opencode.jsonc"
  fi
else
  cecho "yellow" "Global opencode.jsonc file already exists at ~/.config/opencode/opencode.jsonc"
fi

# Create global opencode-mem.jsonc file if it doesn't exist;
# on explicit override MERGE template into the existing config with --live-wins
# so the user's live values (web UI host/auth, provider, …) are never reset.
if [[ ! -f "$HOME/.config/opencode/opencode-mem.jsonc" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if [[ -f "$HOME/.config/opencode/opencode-mem.jsonc" ]]; then
      if command -v python3 >/dev/null 2>&1; then
        if python3 "$RDIR/opencode/merge-opencode-config.py" --live-wins \
          "$RDIR/opencode/opencode-mem.jsonc" "$HOME/.config/opencode/opencode-mem.jsonc"; then
          cecho "green" "Merged template into existing opencode-mem.jsonc (live config preserved)"
        else
          cecho "red" "Failed to merge template into existing opencode-mem.jsonc; existing config kept."
        fi
      else
        cecho "red" "python3 not found — cannot merge; existing opencode-mem.jsonc kept, template NOT applied."
      fi
    else
      if cp "$RDIR/opencode/opencode-mem.jsonc" "$HOME/.config/opencode/opencode-mem.jsonc"; then
        cecho "green" "Global opencode-mem.jsonc file created at ~/.config/opencode/opencode-mem.jsonc"
      else
        cecho "red" "Failed to create global opencode-mem.jsonc file."
      fi
    fi
  else
    cecho "yellow" "DRY-RUN: merge or cp opencode-mem.jsonc -> $HOME/.config/opencode/opencode-mem.jsonc"
  fi
else
  cecho "yellow" "Global opencode-mem.jsonc file already exists at ~/.config/opencode/opencode-mem.jsonc"
fi

# Create global tui.json file if it doesn't exist
if [[ ! -f "$HOME/.config/opencode/tui.json" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if cp "$RDIR/opencode/tui.json" "$HOME/.config/opencode/tui.json"; then
      cecho "green" "Global tui.json file created at ~/.config/opencode/tui.json"
    else
      cecho "red" "Failed to create global tui.json file."
    fi
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/opencode/tui.json $HOME/.config/opencode/tui.json"
  fi
else
  cecho "yellow" "Global tui.json file already exists at ~/.config/opencode/tui.json"
fi

# Create global AGENTS.md file if it doesn't exist
if [[ ! -f "$HOME/.config/opencode/AGENTS.md" ]] || [[ "$OC_OVERRIDE_CONFIG" == true ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if cp "$RDIR/opencode/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"; then
      cecho "green" "Global AGENTS.md file created at ~/.config/opencode/AGENTS.md"
    else
      cecho "red" "Failed to create global AGENTS.md file."
    fi
  else
    cecho "yellow" "DRY-RUN: cp $RDIR/opencode/AGENTS.md $HOME/.config/opencode/AGENTS.md"
  fi
else
  cecho "yellow" "Global AGENTS.md file already exists at ~/.config/opencode/AGENTS.md"
fi

# Create missing skills/agents
copy_files_if_missing "$RDIR/opencode/agents"  "$HOME/.config/opencode/agents"  "*.md" "$OC_OVERRIDE_CONFIG"
copy_skills_if_missing  "$RDIR/opencode/skills" "$HOME/.config/opencode/skills" "$OC_OVERRIDE_CONFIG"
