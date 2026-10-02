#!/bin/bash

###
# OpenCode install script
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
cecho "cyan" "Installing [opencode]..."

# Check if already installed
if opencode --version >/dev/null 2>&1; then
  cecho "yellow" "[opencode] is already present. Updating it..."
fi

# A package-managed V1 install can shadow the V2 binary placed by the curl
# installer, so warn and let the user remove it first.
if command -v opencode >/dev/null 2>&1; then
  OC_BIN="$(command -v opencode)"
  if { command -v pacman >/dev/null 2>&1 && pacman -Qo "$OC_BIN" >/dev/null 2>&1; } \
    || { command -v dpkg >/dev/null 2>&1 && dpkg -S "$OC_BIN" >/dev/null 2>&1; } \
    || { command -v rpm >/dev/null 2>&1 && rpm -qf "$OC_BIN" >/dev/null 2>&1; }; then
    cecho "yellow" "[opencode] is package-managed ($OC_BIN). Remove the package before installing V2."
  fi
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  curl -fsSL https://opencode.ai/v2/install | bash
else
  cecho "yellow" "DRY-RUN: curl -fsSL https://opencode.ai/v2/install | bash"
fi
