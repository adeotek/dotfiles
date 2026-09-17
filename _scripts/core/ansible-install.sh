#!/bin/bash

###
# Ansible install script
# Installs ansible and ansible-lint via uv tool install
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
cecho "cyan" "Installing [ansible]..."

# Ensure uv is available
if ! command -v uv >/dev/null 2>&1; then
  source "$CDIR/uv-install.sh"
fi

# Clean up old package manager installations
ANS_CLEANUP=false
if [[ "${ARGS["unattended"]}" != "1" ]]; then
  read_yes_no "Do you want to run the clean-up for old installations? (y/N): " "n"
  if [[ "$REPLY_YN" == "y" ]]; then
    ANS_CLEANUP=true
  fi
fi
if [[ "$ANS_CLEANUP" == true ]]; then
  source "$CDIR/ansible-cleanup.sh"
fi

# Install ansible via uv tool install
# The PyPI `ansible` metapackage only declares the `ansible-community` entry point;
# the `ansible` executable comes from the ansible-core dependency, so it must be
# exposed explicitly via --with-executables-from (uv does not expose dependency
# executables by default).
if command -v ansible >/dev/null 2>&1; then
  cecho "yellow" "[ansible] is already present. Updating it..."
  execute_command "uv tool upgrade ansible" "[ansible] update done."
else
  # Fallback to --force covers tools installed by older script versions
  # (installed in uv but not exposed on PATH)
  execute_command "uv tool install ansible --with-executables-from ansible-core || uv tool install --force ansible --with-executables-from ansible-core" "[ansible] installation done."
fi

# Install ansible-lint via uv tool install
if command -v ansible-lint >/dev/null 2>&1; then
  cecho "yellow" "[ansible-lint] is already present. Updating it..."
  execute_command "uv tool upgrade ansible-lint" "[ansible-lint] update done."
else
  execute_command "uv tool install ansible-lint" "[ansible-lint] installation done."
fi

# Verify
if [[ "$DRY_RUN" -ne "1" ]]; then
  if command -v ansible >/dev/null 2>&1; then
    cecho "green" "[ansible] $(ansible --version 2>/dev/null | head -1 || echo 'installed') successfully."
  else
    cecho "red" "[ansible] installation failed — 'ansible' command not found after install."
    exit 1
  fi
  if command -v ansible-lint >/dev/null 2>&1; then
    cecho "green" "[ansible-lint] $(ansible-lint --version 2>/dev/null | head -1 || echo 'installed') successfully."
  else
    cecho "red" "[ansible-lint] installation failed — 'ansible-lint' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: ansible --version"
  cecho "yellow" "DRY-RUN: ansible-lint --version"
fi
