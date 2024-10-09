#!/bin/bash

###
# Ansible setup script
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
cecho "yellow" "WARNING: Ansible setup not implemented yet!"

# case $CURRENT_OS_ID in
#   arch)
#     
#   ;;
#   debian)
#  # Create ansible config file
# rm ~/.ansible.cfg
# tee -a ~/.ansible.cfg <<EOF
# [defaults]
# inventory=inventory
# privatekeyfile=~/.ssh/id_rsa
# remote_user=$LINUX_USER
# roles_path=~/ansible/roles
# filter_plugins=~/ansible/filter_plugins
# [privilege_escalation]
# become=True
# EOF   
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
