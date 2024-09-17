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
  TARGET_VERSION="20"
else
  if [ "${ARGS["version"]}" == "current" ]; then
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
  case $CURRENT_OS_ID in
    arch)
      sudo pacman -R --noconfirm nodejs npm
    ;;
    debian)
      sodo -i
      curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh
      bash nodesource_setup.sh
      rm -f nodesource_setup.sh
      apt update && apt install -y nodejs
      exit
    ;;
    ubuntu)
      curl -fsSL https://deb.nodesource.com/setup_$TARGET_VERSION.x -o nodesource_setup.sh
      sudo -E bash nodesource_setup.sh
      rm -f nodesource_setup.sh
      sudo apt update && sudo apt install -y nodejs
    ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
    ;;
  esac
fi

sudo npm install --upgrade -g npm

