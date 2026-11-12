#!/bin/bash

###
# .NET install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  # Reset first, so the --upgrade opt-in of a previous run cannot leak in
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["version"]="$OPT_DOTNET_DEFAULT_VERSION"
  else
    ARGS["version"]=""
  fi
  ARGS["upgrade"]=""
else
  declare -A ARGS=(["version"]="" ["upgrade"]="")
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
process_args "$@"

# Helpers

function dotnet_major_version() {
  # Extracts the major version number: "11.0.100" and "11.0" both give "11"
  local version="${1#v}"
  version="${version%%.*}"
  if [[ "$version" =~ ^[0-9]+$ ]]; then
    echo "$version"
  fi
}

function get_dotnet_version() {
  # Sets DOTNET_VERSION (from --version or an interactive prompt) and
  # DOTNET_TARGET_VERSION (the version used for comparisons: on arch the
  # rolling dotnet-sdk package is installed, so the default is used)
  if [[ -z "${ARGS["version"]}" && "$CURRENT_OS_ID" != "arch" ]]; then
    cecho "yellow" -n "Please specify the .NET version to install [$OPT_DOTNET_DEFAULT_VERSION]: "
    read -r DOTNET_VERSION
    if [[ -z "$DOTNET_VERSION" ]]; then
      DOTNET_VERSION="$OPT_DOTNET_DEFAULT_VERSION"
    fi
    ARGS["version"]="$DOTNET_VERSION"
  else
    DOTNET_VERSION="${ARGS["version"]}"
  fi
  DOTNET_TARGET_VERSION="${DOTNET_VERSION:-$OPT_DOTNET_DEFAULT_VERSION}"
}

# Guard: skip installation when dotnet is already available.
# Only an explicit request coming from the setup flows (--upgrade, passed by
# setup.sh and unattended_setup.sh) asks for the version and upgrades; scripts
# that source this file as a dependency keep skipping.
DOTNET_INSTALL_NEEDED="0"
if command -v dotnet >/dev/null 2>&1; then
  DOTNET_CURRENT_VERSION="$(dotnet --version 2>/dev/null | head -n 1)"
  if [[ "${ARGS["upgrade"]}" != "1" ]]; then
    cecho "yellow" "[dotnet] is already present. Skipping installation."
  else
    get_dotnet_version
    DOTNET_CURRENT_MAJOR="$(dotnet_major_version "$DOTNET_CURRENT_VERSION")"
    DOTNET_TARGET_MAJOR="$(dotnet_major_version "$DOTNET_TARGET_VERSION")"
    if [[ -z "$DOTNET_CURRENT_VERSION" || -z "$DOTNET_CURRENT_MAJOR" || -z "$DOTNET_TARGET_MAJOR" ]]; then
      cecho "yellow" "[dotnet] cannot compare the installed version [$DOTNET_CURRENT_VERSION] with the requested one [$DOTNET_TARGET_VERSION]. Skipping installation."
    elif [[ "$DOTNET_TARGET_MAJOR" -gt "$DOTNET_CURRENT_MAJOR" ]]; then
      cecho "yellow" "[dotnet] upgrading from [$DOTNET_CURRENT_VERSION] to the requested version [$DOTNET_TARGET_VERSION]..."
      DOTNET_INSTALL_NEEDED="1"
    else
      cecho "green" "[dotnet] is already present at [$DOTNET_CURRENT_VERSION], which is not older than the requested version [$DOTNET_TARGET_VERSION]. Skipping installation."
    fi
  fi
else
  DOTNET_INSTALL_NEEDED="1"
fi

if [[ "$DOTNET_INSTALL_NEEDED" == "1" ]]; then
  # Install
  get_dotnet_version

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
        if ! grep -q "dotnet/backports" /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources 2>/dev/null; then
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
      dotnet tool install -g Adeotek.DevOpsTools || dotnet tool update -g Adeotek.DevOpsTools
    else
      cecho "yellow" "DRY-RUN: dotnet tool install -g Adeotek.DevOpsTools || dotnet tool update -g Adeotek.DevOpsTools"
    fi
  fi
fi
