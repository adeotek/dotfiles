#!/bin/bash

###
# Powershell install script
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
case $CURRENT_OS_ID in
  arch)
    install_package "powershell" "pwsh --version" "yay -S --noconfirm --needed powershell"
    ;;
  debian)
    if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
      cecho "cyan" "Installing Microsoft APT source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
        wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        decho "magenta" "sudo dpkg -i packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        decho "magenta" "rm packages-microsoft-prod.deb"
        rm packages-microsoft-prod.deb
        decho "magenta" "sudo apt update"
        sudo apt update
      else
        cecho "yellow" "DRY-RUN: wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: sudo dpkg -i packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: rm packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: sudo apt update"
      fi
    fi
    install_package "powershell" "pwsh --version"
    ;;
  ubuntu)
    if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
      cecho "cyan" "Installing Microsoft APT source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
        wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        decho "magenta" "sudo dpkg -i packages-microsoft-prod.deb"
        sudo dpkg -i packages-microsoft-prod.deb
        decho "magenta" "rm packages-microsoft-prod.deb"
        rm packages-microsoft-prod.deb
        decho "magenta" "sudo apt update"
        sudo apt update
      else
        cecho "yellow" "DRY-RUN: wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: sudo dpkg -i packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: rm packages-microsoft-prod.deb"
        cecho "yellow" "DRY-RUN: sudo apt update"
      fi
    fi
    install_package "powershell" "pwsh --version"
    ;;
  fedora|redhat|centos|almalinux)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
      sudo dnf makecache
    else
      cecho "yellow" "DRY-RUN: sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc"
      cecho "yellow" "DRY-RUN: curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo"
      cecho "yellow" "DRY-RUN: sudo dnf makecache"
    fi
    install_package "powershell" "pwsh --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
