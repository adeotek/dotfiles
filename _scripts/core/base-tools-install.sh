#!/bin/bash

###
# Base tools install script
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
if [ "$DRY_RUN" -ne "1" ]; then
  case $CURRENT_OS_ID in
    arch)
      ## Base tools
      sudo pacman -S --noconfirm --needed curl wget mc netcat nano vi whois mandoc micro
      ## CLI tools
      sudo pacman -S --noconfirm --needed jq fd ripgrep fzf bat tree htop hstr zoxide bash-completion stow
      ## eza (ls alternative)
      sudo pacman -S --noconfirm --needed eza
      ;;
    debian|ubuntu|pop)
      ## Distro tools
      if [ "$CURRENT_OS_ID" != "debian" ] || [ "$CURRENT_OS_VER" != "13" ]; then
        sudo apt-get install -y software-properties-common
      fi
      sudo apt-get install -y apt-transport-https gpg gnupg
      ## Base tools
      sudo apt-get install -y curl wget mc netcat-traditional nano whois micro
      ## CLI tools
      sudo apt-get install -y jq fd-find ripgrep bat tree htop hstr zoxide bash-completion stow
      mkdir -p ~/.local/bin
      if [ ! -f ~/.local/bin/fd ]; then
        ln -s $(which fdfind) ~/.local/bin/fd
      fi
      if [ ! -f ~/.local/bin/bat ]; then
        ln -s $(which batcat) ~/.local/bin/bat
      fi

      if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install
      else
        source "$CDIR/homebrew-install.sh"
        brew install fzf
        ## eza (ls alternative)
        brew install eza
      fi
      ;;
    fedora|redhat)
      ## Distro tools
      sudo dnf install -y gpg make gcc glibc-devel glibc-headers tar unzip
      ## Base tools
      sudo dnf install -y curl wget mc nc nano whois micro
      ## CLI tools
      sudo dnf install -y file jq ripgrep bat tree htop hstr zoxide bash-completion stow fzf fd-find
      if [ "$CURRENT_OS_ID" != "fedora" ]; then
        cecho "yellow" "Skipping eza for RHEL-based distros due to missing package"
      else
        sudo dnf copr enable alternateved/eza -y
        sudo dnf install -y eza
      fi
      ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
      ;;
  esac
else
  cecho "yellow" "DRY-RUN: Installing base tools:"
  cecho "yellow" "DRY-RUN: curl wget mc netcat nano whois jq fd-find ripgrep bat tree htop hstr zoxide bash-completion stow fzf fd eza"
fi
