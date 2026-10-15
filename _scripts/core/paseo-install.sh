#!/bin/bash

###
# Paseo daemon install script
#
# Installs @getpaseo/cli system-wide (via sudo, explicitly NOT the user-level
# $HOME/.local NPM prefix) and deploys the paseo-daemon systemd user unit.
# See docs/paseo.md for details.
###

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
source "$CDIR/nodejs-install.sh"

cecho "cyan" "Installing [paseo]..."

# System-wide install (avoids a user-level $HOME/.local npm prefix)
NPM_CMD="sudo env PATH=$PATH npm"

# npm >= 11.5 blocks package postinstall scripts by default; paseo's esbuild
# and node-pty deps need theirs. Older npm rejects the unknown flag — fall
# back to a plain install (scripts run by default there).
if ! execute_command "$NPM_CMD install -g --allow-scripts=esbuild,node-pty @getpaseo/cli" "[paseo] CLI installed."; then
  execute_command "$NPM_CMD install -g @getpaseo/cli" "[paseo] CLI installed (no allow-scripts fallback)." || exit 1
fi

# --- WSL systemd ---
if [[ "$DRY_RUN" -ne "1" ]]; then
  enable_wsl_systemd
fi

# --- Deploy systemd user unit ---
copy_files_if_missing "$RDIR/paseo/.config/systemd/user" "$HOME/.config/systemd/user" "*.service"

# --- Reload systemd and (re)start the daemon ---
if [[ "$DRY_RUN" -ne "1" ]]; then
  if [[ "$IF_WSL2" == "1" && ! -d /run/systemd/system ]]; then
    cecho "yellow" "WARNING: systemd is not running in this WSL2 session yet. Edit /etc/wsl.conf ([boot] systemd=true), run 'wsl --shutdown' from Windows, reopen, and re-run to activate the paseo-daemon unit."
  else
    if systemctl --user daemon-reload; then
      cecho "green" "systemd user daemon reloaded."
    else
      cecho "red" "Failed to reload systemd user daemon (is a systemd user session available?)."
    fi
    # --- Enable lingering (daemon survives logout / starts at boot) ---
    enable_lingering "paseo-daemon"
    if systemctl --user is-enabled --quiet paseo-daemon.service; then
      if systemctl --user restart paseo-daemon.service; then
        cecho "green" "[paseo] daemon restarted."
      else
        cecho "red" "[paseo] failed to restart the daemon."
      fi
    else
      if systemctl --user enable --now paseo-daemon.service; then
        cecho "green" "[paseo] daemon enabled and started."
      else
        cecho "red" "[paseo] failed to enable and start the daemon."
      fi
    fi
  fi
else
  cecho "yellow" "DRY-RUN: systemctl --user daemon-reload"
  enable_lingering "paseo-daemon"
  cecho "yellow" "DRY-RUN: systemctl --user restart paseo-daemon.service (or enable --now if not enabled)"
fi

# --- Register installed ACP agents (moca, hermes) with the daemon ---
# `paseo daemon config set agents.providers ...` replaces the whole dynamic
# providers map, so the current value is read and the ACP entries are merged
# into it. Only agents whose CLI is actually installed on this host are added.
register_acp_agents() {
  local acp_defs=()
  local acp_def acp_id acp_label acp_cmd
  local original_json providers_json names

  if command -v moca >/dev/null 2>&1; then
    acp_defs+=("moca|moca|moca acp")
  fi
  if command -v hermes >/dev/null 2>&1; then
    acp_defs+=("hermes|Hermes|hermes acp")
  fi

  if [[ ${#acp_defs[@]} -eq 0 ]]; then
    cecho "yellow" "[paseo] No ACP agents (moca, hermes) found on this host — skipping provider registration."
    return 0
  fi

  if ! command -v jq >/dev/null 2>&1; then
    cecho "red" "[paseo] jq is required to register ACP agents — skipping provider registration."
    return 0
  fi

  if [[ "$DRY_RUN" -ne "1" ]] && ! command -v paseo >/dev/null 2>&1; then
    cecho "red" "[paseo] 'paseo' command not found — skipping ACP provider registration."
    return 0
  fi

  # Start from the current providers map (empty object when unset or null).
  original_json="$(paseo daemon config get agents.providers 2>/dev/null | jq -c '.value // {}')" || original_json=""
  providers_json="$original_json"
  if [[ -z "$providers_json" ]]; then
    providers_json='{}'
  fi

  names=()
  for acp_def in "${acp_defs[@]}"; do
    IFS='|' read -r acp_id acp_label acp_cmd <<< "$acp_def"
    providers_json="$(jq -c \
      --arg id "$acp_id" --arg label "$acp_label" --arg cmd "$acp_cmd" \
      '.[$id] = {"extends": "acp", "label": $label, "command": ($cmd | split(" "))}' \
      <<< "$providers_json")" || providers_json=""
    names+=("$acp_id")
  done

  if [[ -z "$providers_json" ]]; then
    cecho "red" "[paseo] Failed to build the ACP providers JSON — skipping provider registration."
    return 1
  fi

  if [[ "$providers_json" == "$original_json" ]]; then
    cecho "green" "[paseo] ACP agents already registered: ${names[*]}"
    return 0
  fi

  if [[ "$DRY_RUN" -ne "1" ]]; then
    if paseo daemon config set agents.providers "$providers_json" >/dev/null; then
      cecho "green" "[paseo] ACP agents registered: ${names[*]}."
      if paseo reload >/dev/null 2>&1; then
        cecho "green" "[paseo] daemon config reloaded."
      else
        cecho "yellow" "[paseo] registered ACP agents but failed to reload the daemon — restart paseo-daemon to apply."
      fi
    else
      cecho "red" "[paseo] failed to register ACP agents."
      return 1
    fi
  else
    cecho "yellow" "DRY-RUN: paseo daemon config set agents.providers '$providers_json'"
    cecho "yellow" "DRY-RUN: paseo reload"
  fi
}

register_acp_agents

# Verify
if [[ "$DRY_RUN" -ne "1" ]]; then
  if command -v paseo >/dev/null 2>&1; then
    cecho "green" "[paseo] $(paseo --version 2>/dev/null || echo 'installed') successfully."
  else
    cecho "red" "[paseo] installation failed — 'paseo' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: paseo --version"
fi

cecho "cyan" "Next: configure the daemon ('paseo daemon config set daemon.listen 0.0.0.0:6767' and 'paseo daemon set-password') — see docs/paseo.md."
