#!/bin/bash

###
# Ansible install script
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
cecho "yellow" "WARNING: Ansible install not implemented yet!"

# case $CURRENT_OS_ID in
#   arch)
#     
#   ;;
#   debian)
#     # Install base tools and Python 3 (required by Ansible)
# sudo apt install -y curl wget netcat nano git mc whois bash-completion hstr libffi-dev libssl-dev python3-pip python3-venv sshpass
# if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
#   echo "" >> ~/.bashrc
#   echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
# fi
# python3 -m pip install --upgrade pip
#
# # Install Ansible and it's dependencies
# sudo apt install -y ansible
# python3 -m pip install ansible-lint
#   ;;
#   ubuntu)
#     
#   ;;
#   *)
#     cecho "red" "Unsupported OS: $CURRENT_OS_ID"
#     exit 1
#   ;;
# esac
#
