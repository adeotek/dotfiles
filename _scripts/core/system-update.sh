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
    sudo pacman -Suy --noconfirm
    yay -Suy --noconfirm
    ;;
  debian|ubuntu|pop)
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get autoremove -y
    ;;
  fedora|redhat|centos|almalinux)
    # Check if EPEL repo is installed
    if ! sudo dnf repolist | grep -q "epel"; then
      cecho "yellow" "EPEL repository is not installed. Installing it now..."
      # Enable CRB repository
      sudo dnf config-manager --set-enabled crb
      # Install EPEL repository
      sudo dnf install -y epel-release
      if [ $? -eq 0 ]; then
        cecho "green" "EPEL repository installed successfully."
      else
        cecho "red" "Failed to install EPEL repository. Please install it manually."
        exit 1
      fi
    fi
    sudo dnf upgrade -y --refresh
    sudo dnf groupupdate core -y
    sudo dnf autoremove -y
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac
