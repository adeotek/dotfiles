#!/bin/bash

###
# Base tools install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
case $CURRENT_OS_ID in
  arch)
    ## Base tools
    sudo pacman -S --noconfirm --needed curl wget mc netcat nano vi whois mandoc
    ## CLI tools
    sudo pacman -S --noconfirm --needed jq fd ripgrep fzf tldr bat tree htop zoxide bash-completion stow
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
    sudo apt install -y jq fd-find ripgrep tldr bat tree htop zoxide bash-completion stow
    if [ ! -f ~/.local/bin/fd ]; then 
      ln -s $(which fdfind) ~/.local/bin/fd
    fi
    brew install fzf
    ## eza (ls alternative)
    brew install -y eza
  ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
  ;;
esac

if [[ "$CURRENT_OS_ID" == "ubuntu" && ! -f "~/.local/bin/bat" ]]; then
  mkdir -p ~/.local/bin 
  ln -s /usr/bin/batcat ~/.local/bin/bat
fi

