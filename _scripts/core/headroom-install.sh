#!/bin/bash

###
# Headroom install script
# Installs headroom-ai[all] (Python LLM proxy) via uv tool install
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
cecho "cyan" "Installing [headroom]..."

# Ensure uv is available
if ! command -v uv >/dev/null 2>&1; then
  source "$CDIR/uv-install.sh"
fi

# Ensure a compatible Python version is available.
# hnswlib (a C++ dependency pulled in by [all]) does not compile with
# Python 3.14+. We pin to 3.13 for a balance of compatibility and performance.
PYTHON_VERSION="3.13"
if command -v python3 >/dev/null 2>&1; then
  current_python_version=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
  if [[ "$current_python_version" =~ ^3\.1[4-9] ]] || [[ "$current_python_version" =~ ^3\.[2-9][0-9] ]]; then
    cecho "yellow" "Detected Python $current_python_version which is incompatible with hnswlib."
    cecho "cyan" "Installing Python $PYTHON_VERSION via uv for the headroom tool..."
    if [ "$DRY_RUN" -ne "1" ]; then
      uv python install "$PYTHON_VERSION"
    else
      cecho "yellow" "DRY-RUN: uv python install $PYTHON_VERSION"
    fi
  fi
fi

# Install headroom-ai[all] via uv tool install
if command -v headroom >/dev/null 2>&1; then
  cecho "yellow" "[headroom] is already present. Updating it..."
fi

if [ "$DRY_RUN" -ne "1" ]; then
  uv tool install --python "python${PYTHON_VERSION}" 'headroom-ai[all]'
  cecho "green" "[headroom] installation done."
else
  cecho "yellow" "DRY-RUN: uv tool install --python python${PYTHON_VERSION} 'headroom-ai[all]'"
fi

# Verify
if [ "$DRY_RUN" -ne "1" ]; then
  if command -v headroom >/dev/null 2>&1; then
    cecho "green" "[headroom] $(headroom --version 2>/dev/null || echo 'installed') successfully."
  else
    cecho "red" "[headroom] installation failed — 'headroom' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: headroom --version"
fi
