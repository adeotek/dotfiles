#!/bin/bash

###
# NodeJS install script
###

# Init
declare -A ARGS=(
  ["version"]=""
)
if [[ -d "${0%/*}" ]]; then
  IDIR=${0%/*}
else
  IDIR="$PWD";
fi
if [[ -z "$VV" ]]; then
  . "$IDIR/helpers.sh"
fi

# Install
if [ -z "${ARGS["version"]}" ]; then
  TARGET_VERSION="@20"
else
  if [ "${ARGS["version"]}" == "current" ]; then
    TARGET_VERSION=""
  else
    TARGET_VERSION="${ARGS["version"]}"
  fi
fi

install_package "node" "node -v" "brew install node$TARGET_VERSION"
if ! grep -q "export PATH=""/home/linuxbrew/.linuxbrew/opt/node$TARGET_VERSION/bin:\$PATH""" /home/$USER/.bash_profile; then
  echo "export PATH=""/home/linuxbrew/.linuxbrew/opt/node$TARGET_VERSION/bin:\$PATH""" >> /home/$USER/.bash_profile
  source $HOME/.bash_profile
fi
npm install -g npm
