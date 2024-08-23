#!/bin/bash

###
# Base tools install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}/_scripts/core"
  else
    CDIR="$PWD/_scripts/core";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
case $CURRENT_OS_ID in
  arch)arch
    ## Base tools
    sudo pacman -S --noconfirm --needed curl wget mc netcat nano vi whois
    ## CLI tools
    sudo pacman -S --noconfirm --needed jq fd ripgrep fzf tldr bat tree htop zoxide bash-completion
    ## eza (ls alternative)
    sudo pacman -S --noconfirm --needed eza
  ;;
  debian|ubuntu)
    . "$CDIR/homebrew-install.sh"
    ## Distro tools
    sudo apt install -y software-properties-common apt-transport-https gpg
    ## Base tools
    sudo apt install -y curl wget mc netcat-traditional nano whois
    ## CLI tools
    sudo apt install -y jq fd-find ripgrep tldr bat tree htop zoxide bash-completion
    ln -s $(which fdfind) ~/.local/bin/fd
    brew install fzf
    ## eza (ls alternative)
    if [ ! -f /etc/apt/sources.list.d/gierens.list ]; then
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt update
    fi
    sudo apt install -y eza
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac
