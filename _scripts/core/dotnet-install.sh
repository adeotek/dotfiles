#!/bin/bash

###
# .NET install script
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
cecho "yellow" -n "Please specify the version to install [8.0]: "
read DOTNET_VERSION
if [[ -z "$DOTNET_VERSION" ]]; then
  DOTNET_VERSION="8.0"
fi
case $CURRENT_OS_ID in
  arch)
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
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
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
  ;;
  ubuntu)
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
