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
  debian|ubuntu|pop)
    if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
      cecho "yellow" "SKIPPED: not available on ARM-based systems."
    else
      if [ "$CURRENT_OS_ID" != "debian" ] || [ "$CURRENT_OS_VER" != "13" ]; then
        cecho "yellow" "SKIPPED: not available yet on Debian 13 systems."
      else
        PWSH_PACKAGE_URL="$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | jq -r '.assets[] | select(.name | contains(".deb_amd64.deb")) | .browser_download_url')"
        if [ "$DRY_RUN" -ne "1" ]; then
          decho "magenta" "wget $PWSH_PACKAGE_URL -O /tmp/powershell.deb"
          wget "$PWSH_PACKAGE_URL" -O /tmp/powershell.deb
          decho "magenta" "sudo apt-get install /tmp/powershell.deb -y"
          sudo apt-get install /tmp/powershell.deb -y
          decho "magenta" "rm -f /tmp/powershell.deb"
          rm -f /tmp/powershell.deb
        else
          cecho "yellow" "DRY-RUN: wget $PWSH_PACKAGE_URL -O /tmp/powershell.deb"
          cecho "yellow" "DRY-RUN: sudo apt-get install /tmp/powershell.deb -y"
          cecho "yellow" "DRY-RUN: rm -f /tmp/powershell.deb"
        fi
      fi
    fi
    ;;
  fedora|redhat|centos|almalinux)
    PWSH_PACKAGE_URL="$(curl -s https://api.github.com/repos/PowerShell/PowerShell/releases/latest | jq -r '.assets[] | select(.name | contains(".rh.x86_64.rpm")) | .browser_download_url')"
    if [ "$DRY_RUN" -ne "1" ]; then
      decho "magenta" "wget $PWSH_PACKAGE_URL -O /tmp/powershell.rpm"
      wget "$PWSH_PACKAGE_URL" -O /tmp/powershell.rpm
      decho "magenta" "sudo dnf install /tmp/powershell.rpm -y"
      sudo dnf install /tmp/powershell.rpm -y
      decho "magenta" "rm -f /tmp/powershell.rpm"
      rm -f /tmp/powershell.rpm
    else
      cecho "yellow" "DRY-RUN: wget $PWSH_PACKAGE_URL -O /tmp/powershell.rpm"
      cecho "yellow" "DRY-RUN: sudo dnf install /tmp/powershell.rpm -y"
      cecho "yellow" "DRY-RUN: rm -f /tmp/powershell.rpm"
    fi
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
