#!/bin/bash

###
# HomeBrew install script
###

# Init
if [[ -z "$BDIR" ]]; then
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
  decho "yellow" "HomeBrew is already installed!"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ## Set shell profile
  # if echo $SHELL | grep -q "/zsh" >/dev/null; then
  #   SHELL_PROFILE=".zshrc"
  # else
  #   SHELL_PROFILE=".bashrc"
  # fi
  # if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/$SHELL_PROFILE; then
  #   (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/$SHELL_PROFILE
  # fi
  ## Activate brew
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ## Install gcc
  case $CURRENT_OS_ID in
    arch)
      sudo pacman -S --noconfirm --needed base-devel
    ;;
    debian|ubuntu)
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
  brew install gcc
fi
