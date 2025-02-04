#!/bin/bash

###
# HomeBrew install script
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
if [[ -x "$(command -v brew)" ]]; then
  decho "yellow" "Homebrew is already installed!"
else
  if /home/linuxbrew/.linuxbrew/bin/brew -v >/dev/null 2>&1; then
    cecho "yellow" "Homebrew is installed, but not activated. Activating it for current execution..."
    ## Activate brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ## Activate brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ## Install build tools
    case $CURRENT_OS_ID in
      arch)
        sudo pacman -S --noconfirm --needed base-devel
        ;;
      debian|ubuntu|pop)
        sudo apt install -y build-essential
        ;;
      fedora|redhat|centos|almalinux)
        sudo dnf install -y gcc gcc-c++ glibc-devel glibc-headers make
        ;;
      *)
        cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
        exit 1
      ;;
    esac
    # Install gcc
    brew install gcc
  fi
fi
