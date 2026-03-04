#!/bin/bash

###
# Ghostty install script
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
    install_package "ghostty" "ghostty --version"
  ;;
  debian|ubuntu|pop)
    cecho "cyan" "Installing [ghostty]..."
    if [ ghostty --version >/dev/null 2>&1 ]; then
      decho "yellow" "Package already installed. Updating it..."
    fi

    if [ "$DRY_RUN" -ne "1" ]; then
      decho "magenta" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)\""
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
      cecho "green" "[ghostty] installation done."
    else
      cecho "yellow" "DRY-RUN: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)\""
    fi
  ;;
  fedora)
    if [ "$DRY_RUN" -ne "1" ]; then
      decho "magenta" "sudo dnf copr enable -y scottames/ghostty"
      sudo dnf copr enable -y scottames/ghostty
    else
      cecho "yellow" "DRY-RUN: sudo dnf copr enable -y scottames/ghostty"
    fi
    install_package "ghostty" "ghostty --version"
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
