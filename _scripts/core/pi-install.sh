#!/bin/bash

###
# Pi coding agent install script (managed install)
# https://pi.dev — @earendil-works/pi-coding-agent
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

# pi requires Node.js >= 22.19 at runtime
pi_node_ok() {
  command -v node >/dev/null 2>&1 || return 1
  local major minor
  major=$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null) || return 1
  minor=$(node -p 'process.versions.node.split(".")[1]' 2>/dev/null) || return 1
  if [[ "$major" -gt 22 ]] || { [[ "$major" -eq 22 ]] && [[ "$minor" -ge 19 ]]; }; then
    return 0
  fi
  return 1
}

# Install
cecho "cyan" "Installing [pi]..."

if command -v pi >/dev/null 2>&1; then
  cecho "yellow" "[pi] is already present. Updating it..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if ! pi update --self; then
      cecho "red" "[pi] update failed."
      return 1
    fi
    cecho "green" "[pi] update done."
  else
    cecho "yellow" "DRY-RUN: pi update --self"
  fi
else
  if ! command -v node >/dev/null 2>&1; then
    cecho "yellow" "[pi] requires Node.js >= 22.19 and it was not found. Installing Node.js first..."
    source "$CDIR/nodejs-install.sh"
  elif ! pi_node_ok; then
    cecho "yellow" "[pi] warning: Node.js $(node --version 2>/dev/null) is older than the required 22.19; the installer will verify."
  fi
  if [[ "$DRY_RUN" -ne "1" ]]; then
    # Detach from the tty: the upstream installer's only non-interactive mode is
    # "no terminal detected", which auto-continues and skips its prompts
    # (install/reinstall menu, Node install offer, PATH update offer).
    PI_SETSID=""
    if command -v setsid >/dev/null 2>&1; then
      PI_SETSID="setsid"
    fi
    # shellcheck disable=SC2086  # PI_SETSID is empty (plain sh) or setsid
    if ! (set -o pipefail; curl -fsSL https://pi.dev/install.sh | $PI_SETSID sh); then
      cecho "red" "[pi] installation failed."
      return 1
    fi
    cecho "green" "[pi] installation done."
  else
    cecho "yellow" "DRY-RUN: curl -fsSL https://pi.dev/install.sh | sh"
  fi
fi
