#!/bin/bash

###
# Python install script
###

# Init
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "${0%/*}")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "yellow" "WARNING: Python install not implemented yet!"

## ARCH
# # Setup Python 3
# sudo pacman -S --noconfirm --needed python python-pip python-pipx sshpass
# if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
#   (echo; echo 'export PATH=$PATH:~/.local/bin') >> ~/.bashrc
# fi

## DEBIAN
# sudo apt install -y python3 python3-pip python3-venv pipx sshpass
# if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
#   echo "" >> ~/.bashrc
#   echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
# fi
# # python3 -m pip install --upgrade pip
