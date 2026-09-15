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
  cecho "yellow" -n "Please specify the .NET version to install [$OPT_DOTNET_DEFAULT_VERSION]: "
  read -r DOTNET_VERSION
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
      ;;
    debian)
      if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
        cecho "cyan" "Installing [dotnet-sdk-$DOTNET_VERSION]..."
        if [[ "$DRY_RUN" -ne "1" ]]; then
          DOTNET_INSTALL_SCRIPT="$(mktemp /tmp/dotnet-install.XXXXXX.sh)"
          if wget -q https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O "$DOTNET_INSTALL_SCRIPT" \
             && chmod +x "$DOTNET_INSTALL_SCRIPT"; then
            "$DOTNET_INSTALL_SCRIPT" --channel "$DOTNET_VERSION"
            cecho "green" "[dotnet] installation done."
          else
            cecho "red" "Failed to download dotnet-install.sh."
          fi
          rm -f "$DOTNET_INSTALL_SCRIPT"
        else
          cecho "yellow" "DRY-RUN: wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh -O <tmp>/dotnet-install.sh && <tmp>/dotnet-install.sh --channel \"$DOTNET_VERSION\""
        fi
      else
        source "$CDIR/microsoft-repo-install.sh"
        install_package "dotnet-sdk-$DOTNET_VERSION" "dotnet --version"
      fi
      ;;
    ubuntu|pop)
      if ! grep -q "^deb.*dotnet/backports" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        cecho "cyan" "Enabling dotnet backports Ubuntu feed..."
        if [[ "$DRY_RUN" -ne "1" ]]; then
          sudo add-apt-repository -y ppa:dotnet/backports
          sudo apt-get update
        else
          cecho "yellow" "DRY-RUN: sudo add-apt-repository -y ppa:dotnet/backports"
          cecho "yellow" "DRY-RUN: sudo apt-get update"
        fi
      fi
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
  if [[ "$DRY_RUN" -ne "1" ]]; then
    dotnet tool install -g Adeotek.DevOpsTools
  else
    cecho "yellow" "DRY-RUN: dotnet tool install -g Adeotek.DevOpsTools"
  fi
fi
