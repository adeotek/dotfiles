#!/bin/bash

###
# Docker install script
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
case $CURRENT_OS_ID in
  arch)
    install_package "docker" "sudo docker --version" "_" "docker-compose"
    ;;
  debian)
    if [ "$DRY_RUN" -ne "1" ]; then
      for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
      # Add Docker's official GPG key:
      sudo apt update
      sudo apt install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      # Add the repository to Apt sources:
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt update
    fi
    install_package "docker-ce" "sudo docker --version" "_" "docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    ;;
  ubuntu)
    if [ "$DRY_RUN" -ne "1" ]; then
      for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
      # Add Docker's official GPG key:
      sudo apt update
      sudo apt install -y ca-certificates curl
      sudo install -m 0755 -d /etc/apt/keyrings
      sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
      sudo chmod a+r /etc/apt/keyrings/docker.asc
      # Add the repository to Apt sources:
      echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      sudo apt update
    fi
    install_package "docker-ce" "sudo docker --version" "_" "docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    ;;
  fedora|redhat|centos|almalinux)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo dnf install -y yum-utils
      sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc
      sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      sudo dnf update -y --refresh
    fi
    install_package "docker-ce" "sudo docker --version" "_" "docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

if [ "$DRY_RUN" -ne "1" ]; then
  sudo systemctl enable --now docker
  sudo usermod -aG docker $USER && newgrp docker
fi
