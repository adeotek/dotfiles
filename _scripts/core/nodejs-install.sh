#!/bin/bash

###
# NodeJS install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  ARGS["version"]=""
else
  declare -A ARGS=(["version"]="")
fi
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi
process_args $@

# Install
if [ -z "${ARGS["version"]}" ]; then
  TARGET_VERSION="22"
else
  if [ "${ARGS["version"]}" == "current" || "${ARGS["version"]}" == "lts" ]; then
    TARGET_VERSION="22"
  else
    TARGET_VERSION="${ARGS["version"]}"
  fi
fi

NJS_INSTALL_MODE="source"
if [[ "$CURRENT_ARCH" != "aarch64" ]]; then
  cecho "yellow" -n "Do you want to install NodeJs with Homebrew? [y/N]: "
  read INSTALL_MODE_CONFIRM
  if [[ "$INSTALL_MODE_CONFIRM" == "y" || "$INSTALL_MODE_CONFIRM" == "Y" ]]; then
    NJS_INSTALL_MODE="brew"
  fi 
fi

if [[ "$NJS_INSTALL_MODE" == "brew" ]]; then
  install_package "node" "node -v" "brew install node$TARGET_VERSION"
  if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/node@$TARGET_VERSION/bin* ]]; then
    (echo; echo "export PATH=""\$PATH:/home/linuxbrew/.linuxbrew/opt/node@$TARGET_VERSION/bin""") >> /home/$USER/.bashrc
    source $HOME/.bashrc
  fi
else
  cecho "cyan" "Installing [nodejs]..."
  case $CURRENT_OS_ID in
    arch)
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo pacman -S --noconfirm --needed nodejs npm
        cecho "green" "[nodejs] installation done."
      else
        cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed nodejs npm"
      fi
    ;;
    debian)
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh
        sudo bash nodesource_setup.sh
        sudo rm -f nodesource_setup.sh
        sudo apt update && sudo apt install -y nodejs
        cecho "green" "[nodejs] installation done."
      else
        cecho "yellow" "DRY-RUN: sudo curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: sudo bash nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: sudo rm -f nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: sudo apt update && sudo apt install -y nodejs"
      fi
    ;;
    ubuntu)
      if [ "$DRY_RUN" -ne "1" ]; then
        curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh
        sudo -E bash nodesource_setup.sh
        rm -f nodesource_setup.sh
        sudo apt update && sudo apt install -y nodejs
        cecho "green" "[nodejs] installation done."
      else
        cecho "yellow" "DRY-RUN: curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: sudo -E bash nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: rm -f nodesource_setup.sh"
        cecho "yellow" "DRY-RUN: sudo apt update && sudo apt install -y nodejs"
      fi
    ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
    ;;
  esac
fi

if [ "$DRY_RUN" -ne "1" ]; then
  sudo npm install -g npm
else
  cecho "yellow" "DRY-RUN: sudo npm install -g npm"
fi


