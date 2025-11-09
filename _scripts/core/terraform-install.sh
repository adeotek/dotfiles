#!/bin/bash

###
# Terraform install script
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
    if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
      cecho "cyan" "Installing Hashicorp APT source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
        wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        decho "magenta" "echo ""deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main"" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        decho "magenta" "sudo apt-get update"
        sudo apt-get update
      else
        cecho "yellow" "DRY-RUN: wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
        cecho "yellow" "DRY-RUN: echo ""deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main"" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
    fi
    install_package "terraform" "terraform --version"
    ;;
  fedora)
    if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
      cecho "cyan" "Installing Hashicorp YUM source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "sudo dnf install -y dnf-plugins-core"
        sudo dnf install -y dnf-plugins-core
        decho "magenta" "sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
        sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
      else
        cecho "yellow" "DRY-RUN: sudo dnf install -y dnf-plugins-core"
        cecho "yellow" "DRY-RUN: sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
      fi
    fi
    install_package "terraform" "terraform --version"
    ;;
  redhat|centos|almalinux)
    if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
      cecho "cyan" "Installing Hashicorp YUM source..."
      if [ "$DRY_RUN" -ne "1" ]; then
        decho "magenta" "sudo yum install -y yum-utils"
        sudo yum install -y yum-utils
        decho "magenta" "sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"
        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
      else
        cecho "yellow" "DRY-RUN: sudo yum install -y yum-utils"
        cecho "yellow" "DRY-RUN: sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo"
      fi
    fi
    install_package "terraform" "terraform --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

# Install TFLint
if ! command -v tflint &> /dev/null; then
  cecho "cyan" "Installing TFLint..."
  if [ "$DRY_RUN" -ne "1" ]; then
    decho "magenta" "curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
  else
    cecho "yellow" "DRY-RUN: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"
  fi
fi
