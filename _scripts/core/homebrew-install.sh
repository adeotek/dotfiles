#!/bin/bash

###
# HomeBrew install script
###

# Homebrew 6.0+ enables "ask mode" by default; skip the install/upgrade confirmation
export HOMEBREW_NO_ASK=1

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
if [[ -x "$(command -v brew)" ]]; then
  decho "yellow" "Homebrew is already installed!"
else
  if /home/linuxbrew/.linuxbrew/bin/brew -v >/dev/null 2>&1; then
    cecho "yellow" "Homebrew is installed, but not activated. Activating it for current execution..."
    ## Activate brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if ! (set -o pipefail; curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash); then
        cecho "red" "Homebrew installation failed."
        return 1
      fi
      ## Activate brew
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    else
      cecho "yellow" "DRY-RUN: curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash"
    fi
    ## Install build tools
    case $CURRENT_OS_ID in
      arch)
        install_package "base-devel" "_"
        ;;
      debian|ubuntu|pop)
        install_package "build-essential" "_"
        ;;
      fedora|redhat)
        install_package "gcc" "_" "_" "gcc-c++ glibc-devel glibc-headers make"
        ;;
      *)
        cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
        exit 1
      ;;
    esac
    if [[ "$DRY_RUN" -ne "1" ]]; then
      # Install gcc
      brew install gcc
    else
      cecho "yellow" "DRY-RUN: brew install gcc"
    fi
  fi
fi
