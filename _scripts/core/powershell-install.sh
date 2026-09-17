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

# Guard: skip installation when PowerShell is already available
if command -v pwsh >/dev/null 2>&1; then
  cecho "yellow" "[powershell] is already present. Skipping installation."
  return 0
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
      if [ "$CURRENT_OS_ID" == "debian" ] && [ "$CURRENT_OS_VER" == "13" ]; then
        cecho "yellow" "SKIPPED: not available yet on Debian 13 systems."
      else
        PWSH_PACKAGE_URL="$(curl -fsSL https://api.github.com/repos/PowerShell/PowerShell/releases/latest | jq -r '.assets[] | select(.name | contains(".deb_amd64.deb")) | .browser_download_url' | head -n 1)"
        if [[ -z "$PWSH_PACKAGE_URL" || "$PWSH_PACKAGE_URL" == "null" ]]; then
          cecho "red" "Failed to resolve PowerShell .deb download URL."
          return 1
        fi
        if [[ "$DRY_RUN" -ne "1" ]]; then
          PWSH_DEB_FILE="$(mktemp --suffix=.deb)"
          if wget -q "$PWSH_PACKAGE_URL" -O "$PWSH_DEB_FILE" && sudo apt-get install -y "$PWSH_DEB_FILE"; then
            cecho "green" "[powershell] installation done."
          else
            cecho "red" "[powershell] installation failed."
          fi
          rm -f "$PWSH_DEB_FILE"
        else
          cecho "yellow" "DRY-RUN: wget $PWSH_PACKAGE_URL -O <tmp>.deb && sudo apt-get install -y <tmp>.deb"
        fi
      fi
    fi
    ;;
  fedora|redhat)
    PWSH_RPM_ARCH="$CURRENT_ARCH"
    PWSH_RELEASE_JSON="$(curl -fsSL https://api.github.com/repos/PowerShell/PowerShell/releases/latest)"
    PWSH_PACKAGE_URL="$(jq -r --arg arch "$PWSH_RPM_ARCH" '([.assets[] | select(.name | contains(".rh." + $arch + ".rpm")) | .browser_download_url] + [.assets[] | select(.name | contains("." + $arch + ".rpm")) | .browser_download_url] | .[0]) // empty' <<< "$PWSH_RELEASE_JSON")"
    if [[ -z "$PWSH_PACKAGE_URL" || "$PWSH_PACKAGE_URL" == "null" ]]; then
      cecho "red" "Failed to resolve PowerShell .rpm download URL."
      return 1
    fi
    if [[ "$DRY_RUN" -ne "1" ]]; then
      PWSH_RPM_FILE="$(mktemp --suffix=.rpm)"
      if wget -q "$PWSH_PACKAGE_URL" -O "$PWSH_RPM_FILE" && sudo dnf install -y "$PWSH_RPM_FILE"; then
        cecho "green" "[powershell] installation done."
      else
        cecho "red" "[powershell] installation failed."
      fi
      rm -f "$PWSH_RPM_FILE"
    else
      cecho "yellow" "DRY-RUN: wget $PWSH_PACKAGE_URL -O <tmp>.rpm && sudo dnf install -y <tmp>.rpm"
    fi
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
