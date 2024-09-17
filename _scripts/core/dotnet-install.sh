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
case $CURRENT_OS_ID in
  arch)
    install_package "dotnet-sdk" "dotnet --version"
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo pacman -S --noconfirm --needed aspnet-runtime
      sudo pacman -S --noconfirm --needed aspnet-targeting-pack
    else
      cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed aspnet-runtime"
      cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed aspnet-targeting-pack"
    fi
  ;;
  debian)
    cecho "yellow" -n "Please specify the version to install [8.0]: "
    read DOTNET_VERSION
    if [[ -z "$DOTNET_VERSION" ]]; then
      DOTNET_VERSION="8.0"
    fi

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
    cecho "yellow" -n "Please specify the version to install [8.0]: "
    read DOTNET_VERSION
    if [[ -z "$DOTNET_VERSION" ]]; then
      DOTNET_VERSION="8.0"
    fi
    install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac

