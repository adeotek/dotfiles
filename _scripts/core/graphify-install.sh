#!/bin/bash

###
# graphify install script
# Installs graphify (PyPI: graphifyy) via uv and registers the Claude Code skill
# https://github.com/safishamsi/graphify
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
cecho "cyan" "Installing [graphify]..."

# Ensure uv is available
if ! command -v uv >/dev/null 2>&1; then
  source "$CDIR/uv-install.sh"
fi

# graphify requires Python 3.10+
PYTHON_VERSION="3.13"
if command -v python3 >/dev/null 2>&1; then
  current_python_minor=$(python3 -c 'import sys; print(sys.version_info.minor)')
  current_python_major=$(python3 -c 'import sys; print(sys.version_info.major)')
  if [[ "$current_python_major" -lt 3 ]] || [[ "$current_python_major" -eq 3 && "$current_python_minor" -lt 10 ]]; then
    cecho "yellow" "Detected Python ${current_python_major}.${current_python_minor}; graphify requires Python 3.10+."
    cecho "cyan" "Installing Python $PYTHON_VERSION via uv for graphify..."
    if [ "$DRY_RUN" -ne "1" ]; then
      uv python install "$PYTHON_VERSION"
    else
      cecho "yellow" "DRY-RUN: uv python install $PYTHON_VERSION"
    fi
  fi
fi

# Install graphifyy (PyPI name) with optional extras for MCP, Neo4j, PDF, and watch mode
if command -v graphify >/dev/null 2>&1; then
  cecho "yellow" "[graphify] is already present. Updating it..."
fi

if [ "$DRY_RUN" -ne "1" ]; then
  uv tool install --python "python${PYTHON_VERSION}" 'graphifyy[all]'
  cecho "green" "[graphify] package installation done."
else
  cecho "yellow" "DRY-RUN: uv tool install --python python${PYTHON_VERSION} 'graphifyy[all]'"
fi

# Register the Claude Code skill (~/.claude/skills/graphify/SKILL.md)
if command -v claude >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    claude install graphify
    cecho "green" "[claude] graphify skill registered."
  else
    cecho "yellow" "DRY-RUN: claude install graphify"
  fi
fi

# Verify
if [ "$DRY_RUN" -ne "1" ]; then
  if command -v graphify >/dev/null 2>&1; then
    cecho "green" "[graphify] $(graphify --version 2>/dev/null || echo 'installed') successfully."
  else
    cecho "red" "[graphify] installation failed — 'graphify' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: graphify --version"
fi
