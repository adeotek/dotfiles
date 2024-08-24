#!/bin/bash

###
# Tabby install script
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
cecho "cyan" "Installing [tabby]..."
if [ -f /usr/bin/tabby ]; then
  decho "yellow" "Package already installed. Nothing to do."
else
  cecho "yellow" -n "Please specify the version to install [1.0.211]: "
  read TABBY_VERSION
  if [[ -z "$TABBY_VERSION" ]]; then
    TABBY_VERSION="1.0.211"
  fi

  case $CURRENT_OS_ID in
    arch)
      tabby_package_file="tabby-$TABBY_VERSION-linux-x64.pacman"
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file"
        wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file
        decho "magenta" "sudo pacman -U --noconfirm --needed ~/$tabby_package_file"
        sudo pacman -U --noconfirm --needed ~/$tabby_package_file
        decho "magenta" "rm ~/$tabby_package_file"
        rm ~/$tabby_package_file
        cecho "green" "[tabby] installation done."
      else
        cecho "yellow" "DRY-RUN: wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file"
        cecho "yellow" "DRY-RUN: sudo pacman -U --noconfirm --needed ~/$tabby_package_file"
        cecho "yellow" "DRY-RUN: rm ~/$tabby_package_file"
      fi
    ;;
    debian|ubuntu)
      tabby_package_file="tabby-$TABBY_VERSION-linux-x64.deb"
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file"
        wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file
        decho "magenta" "sudo dpkg -i ~/$tabby_package_file"
        sudo dpkg -i ~/$tabby_package_file
        decho "magenta" "rm ~/$tabby_package_file"
        rm ~/$tabby_package_file
        cecho "green" "[tabby] installation done."
      else
        cecho "yellow" "DRY-RUN: wget https://github.com/Eugeny/tabby/releases/download/v$TABBY_VERSION/$tabby_package_file -O ~/$tabby_package_file"
        cecho "yellow" "DRY-RUN: sudo dpkg -i ~/$tabby_package_file"
        cecho "yellow" "DRY-RUN: rm ~/$tabby_package_file"
      fi
    ;;
    *)
      cecho "red" "Unsupported OS: $CURRENT_OS_ID"
      exit 1
    ;;
  esac
fi
