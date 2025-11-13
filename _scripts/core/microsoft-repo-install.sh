#!/bin/bash

###
# Microsoft packages repository install script
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
    cecho "yellow" "SKIPPED: not required on Arch-based systems."
    ;;
  debian)
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      cecho "yellow" "SKIPPED: not available on ARM-based systems."
    else
      if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
        cecho "cyan" "Installing Microsoft APT source..."
        if [ "$CURRENT_OS_VER" != "13" ]; then
          cecho "yellow" "SKIPPED: not available yet on Debian 13 systems."
        else
          if [ "$DRY_RUN" -ne "1" ]; then
            decho "magenta" "wget https://packages.microsoft.com/config/debian/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
            wget https://packages.microsoft.com/config/debian/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
            decho "magenta" "sudo dpkg -i packages-microsoft-prod.deb"
            sudo dpkg -i packages-microsoft-prod.deb
            decho "magenta" "rm packages-microsoft-prod.deb"
            rm packages-microsoft-prod.deb
            decho "magenta" "sudo apt-get update"
            sudo apt-get update
          else
            cecho "yellow" "DRY-RUN: wget https://packages.microsoft.com/config/debian/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
            cecho "yellow" "DRY-RUN: sudo dpkg -i packages-microsoft-prod.deb"
            cecho "yellow" "DRY-RUN: rm packages-microsoft-prod.deb"
            cecho "yellow" "DRY-RUN: sudo apt-get update"
          fi
        fi
      fi
    fi
    ;;
  ubuntu|pop)
    if [[ "$CURRENT_OS_VER" != "24.10" ]]; then
      if ! grep -q "^deb.*dotnet/backports" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        cecho "cyan" "Enabling dotnet backports Ubuntu feed..."
        if [ "$DRY_RUN" -ne "1" ]; then
          sudo add-apt-repository -y ppa:dotnet/backports
          sudo apt-get update
        else
          cecho "yellow" "DRY-RUN: sudo add-apt-repository -y ppa:dotnet/backports"
          cecho "yellow" "DRY-RUN: sudo apt-get update"
        fi
      fi
    else
      if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
        cecho "cyan" "Installing Microsoft APT source..."
        if [ "$DRY_RUN" -ne "1" ]; then
          decho "magenta" "wget https://packages.microsoft.com/config/ubuntu/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
          wget https://packages.microsoft.com/config/ubuntu/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
          decho "magenta" "sudo dpkg -i packages-microsoft-prod.deb"
          sudo dpkg -i packages-microsoft-prod.deb
          decho "magenta" "rm packages-microsoft-prod.deb"
          rm packages-microsoft-prod.deb
          decho "magenta" "sudo apt-get update"
          sudo apt-get update
        else
          cecho "yellow" "DRY-RUN: wget https://packages.microsoft.com/config/ubuntu/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
          cecho "yellow" "DRY-RUN: sudo dpkg -i packages-microsoft-prod.deb"
          cecho "yellow" "DRY-RUN: rm packages-microsoft-prod.deb"
          cecho "yellow" "DRY-RUN: sudo apt-get update"
        fi
      fi
    fi
    ;;
  fedora|redhat)
    cecho "yellow" "SKIPPED: not required on RHEL-based systems."
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
