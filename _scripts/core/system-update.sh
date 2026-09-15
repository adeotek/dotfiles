#!/bin/bash

###
# System update script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}/.." && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Update
case $CURRENT_OS_ID in
  arch)
    if [[ "$DRY_RUN" -ne "1" ]]; then
      sudo pacman -Suy --noconfirm
      if command -v yay >/dev/null 2>&1; then
        yay -Suy --noconfirm
      else
        decho "yellow" "yay not found; skipping AUR update."
      fi
    else
      cecho "yellow" "DRY-RUN: sudo pacman -Suy --noconfirm"
      cecho "yellow" "DRY-RUN: yay -Suy --noconfirm"
    fi
    ;;
  debian|ubuntu|pop)
    if [[ "$DRY_RUN" -ne "1" ]]; then
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get autoremove -y
    else
      cecho "yellow" "DRY-RUN: sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y"
    fi
    ;;
  fedora|redhat)
    if [[ "$DRY_RUN" -ne "1" ]]; then
      # Check if EPEL repo is installed
      if [ "$CURRENT_OS_ID" != "fedora" ] && ! sudo dnf repolist 2>/dev/null | grep -q epel; then
        cecho "yellow" "EPEL repository is not installed. Installing it now..."
        # Enable CodeReady Builder repository (repo id differs by RHEL major version)
        if [[ "$CURRENT_OS_VER" == 8* ]]; then
          CRB_REPO_ID="codeready-builder"
        else
          CRB_REPO_ID="codeready_builder"
        fi
        sudo dnf config-manager --set-enabled "$CRB_REPO_ID" || decho "yellow" "Could not enable $CRB_REPO_ID; continuing."
        # Install EPEL repository
        if sudo dnf install -y epel-release; then
          cecho "green" "EPEL repository installed successfully."
        else
          cecho "red" "Failed to install EPEL repository. Please install it manually."
          exit 1
        fi
      fi
      sudo dnf upgrade -y --refresh
      if [ "$CURRENT_OS_ID" != "fedora" ]; then
        sudo dnf groupupdate core -y
      fi
      sudo dnf autoremove -y
    else
      cecho "yellow" "DRY-RUN: sudo dnf upgrade -y --refresh && sudo dnf autoremove -y (EPEL/CRB setup if needed)"
    fi
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac
