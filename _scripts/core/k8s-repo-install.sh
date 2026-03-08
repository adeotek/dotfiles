#!/bin/bash

###
# k8s repo install script
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
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
      curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | \
        sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
      echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | \
        sudo tee /etc/apt/sources.list.d/kubernetes.list
      sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    else
      cecho "yellow" "DRY-RUN: sudo apt-get install -y apt-transport-https ca-certificates curl gnupg"
      cecho "yellow" "DRY-RUN: curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
      cecho "yellow" "DRY-RUN: sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
      cecho "yellow" "DRY-RUN: echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list"
      cecho "yellow" "DRY-RUN: sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list"
    fi
    ;;
  fedora|redhat)
    if [ "$DRY_RUN" -ne "1" ]; then
      cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF
    else
      cecho "yellow" "DRY-RUN: cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
EOF"
    fi
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac
