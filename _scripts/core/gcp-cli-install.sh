#!/bin/bash

###
# GCP CLI install script
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
    if [ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]; then
      cecho "cyan" "Installing Google Cloud SDK APT source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg"
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
        decho "magenta" "echo ""deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list"
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
        decho "magenta" "sudo apt-get update"
        sudo apt-get update
      else
        cecho "yellow" "DRY-RUN: curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg"
        cecho "yellow" "DRY-RUN: echo ""deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
    fi
    install_package "google-cloud-cli" "gcloud --version"
    ;;
  fedora|redhat|centos|almalinux)
    if [ ! -f /etc/yum.repos.d/google-cloud-sdk.repo ]; then
      cecho "cyan" "Installing Google Cloud SDK YUM source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "tee -a /etc/yum.repos.d/google-cloud-sdk.repo << ..."
        sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
      else
        cecho "yellow" "DRY-RUN: tee -a /etc/yum.repos.d/google-cloud-sdk.repo << ..."
      fi
    fi
    install_package "google-cloud-cli" "gcloud --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
