#!/bin/bash

###
# moca coding agent setup script
#
# Deploys the moca configuration to <config dir>/moca/:
# - config.jsonc with the default model/provider/limits setup
# - prompts/ with saved slash-command templates (code review, debugging,
#   documenting code)
# Follows the same pattern as opencode-setup.sh / pi-setup.sh: files are
# copied, not stowed, and an existing config is never clobbered — on an
# explicit override it is MERGED so the model saved by /model, a personal
# shell allowlist and extra providers survive.
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

# Create missing slash-command prompt templates (a template that already
# exists is the user's from then on, like the moca-seeded /create-command)
copy_files_if_missing "$RDIR/moca/prompts" "$MOCA_CONFIG_DIR/prompts" "*.md" "$MOCA_OVERRIDE_CONFIG"

# Credential note
cecho "white" "Note: run 'moca login <provider>' (or /login in the TUI) to store an API key; stored keys live in $MOCA_CONFIG_DIR/auth.json."
