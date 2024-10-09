#!/bin/bash

###
# .NET install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["version"]=""
else
  declare -A ARGS=(["version"]="")
fi
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "${0%/*}")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
if [[ -z "${ARGS["version"]}" && "$CURRENT_OS_ID" -ne "arch" ]]; then
  cecho "yellow" -n "Please specify the version to install [8.0]: "
  read DOTNET_VERSION
  if [[ -z "$DOTNET_VERSION" ]]; then
    DOTNET_VERSION="8.0"
  fi
else
  DOTNET_VERSION="${ARGS["version"]}"
fi

case $CURRENT_OS_ID in
  arch)
    install_package "dotnet-sdk" "dotnet --version" "_" "aspnet-runtime aspnet-targeting-pack"
    # if [ "$DRY_RUN" -ne "1" ]; then
    #   sudo pacman -S --noconfirm --needed aspnet-runtime
    #   sudo pacman -S --noconfirm --needed aspnet-targeting-pack
    # else
    #   cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed aspnet-runtime"
    #   cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed aspnet-targeting-pack"
    # fi
    ;;
  debian)
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      cecho "cyan" "Installing [dotnet-sdk-$DOTNET_VERSION]..."
      if [ "$DRY_RUN" -ne "1" ]; then
        wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh
        chmod +x dotnet-install.sh
        ./dotnet-install.sh --channel $DOTNET_VERSION
        cecho "green" "[nodejs] installation done."
      else
        cecho "yellow" "DRY-RUN: wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O dotnet-install.sh"
        cecho "yellow" "DRY-RUN: chmod +x dotnet-install.sh"
        cecho "yellow" "DRY-RUN: ./dotnet-install.sh --channel $DOTNET_VERSION"
      fi
    else   
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
    fi
    ;;
  ubuntu)
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
    ;;
  fedora|redhat|centos|almalinux)
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

# Install Adeotek.DevOpsTools package
if [ "$DRY_RUN" -ne "1" ]; then
  dotnet tool install -g Adeotek.DevOpsTools
else
  cecho "yellow" "DRY-RUN: dotnet tool install -g Adeotek.DevOpsTools"
fi
