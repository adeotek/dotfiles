#!/bin/bash

###
# Ansible install script
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
case $CURRENT_OS_ID in
  arch)
    cecho "yellow" "WARNING: Ansible install not implemented yet!"  
  ;;
  debian)
    if [ ! -f /etc/apt/sources.list.d/ansible.list ]; then
      cecho "cyan" "Enabling ansible ppa repository..."
      UBUNTU_CODENAME="jammy"
      if [ "$DRY_RUN" -ne "1" ]; then
        wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
        sudo apt-get update
      else
        cecho "yellow" "DRY-RUN: wget -O- ""https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367"" | sudo gpg --dearmour -o /usr/share/keyrings/ansible-archive-keyring.gpg"
        cecho "yellow" "DRY-RUN: echo ""deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main"" | sudo tee /etc/apt/sources.list.d/ansible.list"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
    fi
    install_package "ansible" "ansible --version" "" "ansible-lint"
  ;;
  ubuntu|pop)
    if ! grep -q "^deb.*ansible/ansible" /etc/apt/sources.list.d/*.list 2>/dev/null; then
      cecho "cyan" "Enabling ansible ppa repository..."
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:ansible/ansible
        sudo apt-get update
      else
        cecho "yellow" "DRY-RUN: sudo add-apt-repository -y ppa:ansible/ansible"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
    fi
    install_package "ansible" "ansible --version" "" "ansible-lint"
  ;;
  fedora|redhat)
    # EPEL need to be enabled first
    install_package "ansible" "ansible --version" "" "ansible-lint"
  ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
  ;;
esac
