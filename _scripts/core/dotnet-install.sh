#!/bin/bash

###
# .NET install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["version"]="$OPT_DOTNET_DEFAULT_VERSION"
  else
    ARGS["version"]=""
  fi
else
  declare -A ARGS=(["version"]="")
fi
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
if [[ -z "${ARGS["version"]}" && "$CURRENT_OS_ID" != "arch" ]]; then
  cecho "yellow" -n "Please specify the version to install [$OPT_DOTNET_DEFAULT_VERSION]: "
  read DOTNET_VERSION
  if [[ -z "$DOTNET_VERSION" ]]; then
    DOTNET_VERSION="$OPT_DOTNET_DEFAULT_VERSION"
  fi
else
  DOTNET_VERSION="${ARGS["version"]}"
fi

if [[ -z "$DOTNET_VERSION" && "$CURRENT_OS_ID" != "arch" ]]; then
  cecho "red" "No .NET version provided. Skipping..."
else
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
        source "$CDIR/microsoft-repo-install.sh"
        install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
      fi
      ;;
    ubuntu|pop)
      source "$CDIR/microsoft-repo-install.sh"
      install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
      ;;
    fedora|redhat)
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
fi
