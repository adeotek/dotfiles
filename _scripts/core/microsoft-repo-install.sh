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
      if [[ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]]; then
        cecho "cyan" "Installing Microsoft APT source..."
        if [[ "$CURRENT_OS_VER" == "13" ]]; then
          cecho "yellow" "SKIPPED: not available yet on Debian 13 systems."
        else
          if [[ "$DRY_RUN" -ne "1" ]]; then
            MS_REPO_DEB="$(mktemp --suffix=.deb)"
            if wget -q "https://packages.microsoft.com/config/debian/${CURRENT_OS_VER}/packages-microsoft-prod.deb" -O "$MS_REPO_DEB" \
              && sudo dpkg -i "$MS_REPO_DEB" \
              && sudo apt-get update; then
              cecho "green" "Microsoft APT source installed."
            else
              cecho "red" "Failed to install Microsoft APT source."
            fi
            rm -f "$MS_REPO_DEB"
          else
            cecho "yellow" "DRY-RUN: wget https://packages.microsoft.com/config/debian/${CURRENT_OS_VER}/packages-microsoft-prod.deb -O <tmp>.deb && sudo dpkg -i <tmp>.deb && sudo apt-get update"
          fi
        fi
      fi
    fi
    ;;
  ubuntu|pop)
    cecho "yellow" "SKIPPED: not required on Ubuntu-based systems."
    ;;
  fedora|redhat)
    cecho "yellow" "SKIPPED: not required on RHEL-based systems."
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
