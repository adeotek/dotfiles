#!/bin/bash

###
# Powershell install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "yellow" "WARNING: Powershell install not implemented yet!"

## ARCH
# # Install PowerShell Core
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
# sudo dnf makecache
# sudo dnf install -y powershell