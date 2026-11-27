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
  arch)
    install_package "terraform" "terraform --version"
    ;;
  debian|ubuntu|pop)
    HASHICORP_CODENAME="$(. /etc/os-release && echo "${VERSION_CODENAME:-$UBUNTU_CODENAME}")"
    if [ -z "$HASHICORP_CODENAME" ]; then
      HASHICORP_CODENAME="$(lsb_release -cs 2>/dev/null)"
    fi
    if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
      cecho "cyan" "Installing Hashicorp APT source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        HASHICORP_KEY_TMP="$(mktemp)"
        if wget -q -O "$HASHICORP_KEY_TMP" https://apt.releases.hashicorp.com/gpg \
          && sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg "$HASHICORP_KEY_TMP"; then
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $HASHICORP_CODENAME main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
          sudo apt-get update
        else
          cecho "red" "Failed to install Hashicorp APT key."
          return 1
        fi
        rm -f "$HASHICORP_KEY_TMP"
      else
        cecho "yellow" "DRY-RUN: wget -O <tmp> https://apt.releases.hashicorp.com/gpg && sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg <tmp>"
        cecho "yellow" "DRY-RUN: echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $HASHICORP_CODENAME main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
        cecho "yellow" "DRY-RUN: sudo apt-get update"
      fi
    fi
    install_package "terraform" "terraform --version"
    ;;
  fedora)
    if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
      cecho "cyan" "Installing Hashicorp YUM source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        if command -v dnf5 >/dev/null 2>&1; then
          decho "magenta" "sudo dnf install -y dnf5-plugins"
          sudo dnf install -y dnf5-plugins
          decho "magenta" "sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
          sudo dnf config-manager addrepo --from-repofile="https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
        else
          decho "magenta" "sudo dnf install -y dnf-plugins-core"
          sudo dnf install -y dnf-plugins-core
          decho "magenta" "sudo dnf -y config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
          sudo dnf -y config-manager --add-repo "https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
        fi
      else
        cecho "yellow" "DRY-RUN: sudo dnf install -y dnf5-plugins && sudo dnf config-manager addrepo --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo"
      fi
    fi
    install_package "terraform" "terraform --version"
    ;;
  redhat)
    if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
      cecho "cyan" "Installing Hashicorp YUM source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
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
# The upstream install_linux.sh was removed, so download the release archive instead:
# https://github.com/terraform-linters/tflint#installation
if ! command -v tflint &> /dev/null; then
  cecho "cyan" "Installing TFLint..."
  case $CURRENT_ARCH in
    x86_64)
      TFLINT_ARCH="amd64"
      ;;
    aarch64|arm64)
      TFLINT_ARCH="arm64"
      ;;
    armv6l|armv7l)
      TFLINT_ARCH="arm"
      ;;
    i686|i386)
      TFLINT_ARCH="386"
      ;;
    *)
      TFLINT_ARCH=""
      ;;
  esac
  if [[ -z "$TFLINT_ARCH" ]]; then
    cecho "red" "[TFLint] Unsupported architecture: $CURRENT_ARCH"
    return 1
  fi
  TFLINT_URL="https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_${TFLINT_ARCH}.zip"
  install_package "unzip" "command -v unzip"
  if [[ "$DRY_RUN" -ne "1" ]]; then
    TFLINT_ZIP="$(mktemp --suffix=.zip)"
    decho "magenta" "curl -fsSL $TFLINT_URL -o $TFLINT_ZIP"
    if curl -fsSL "$TFLINT_URL" -o "$TFLINT_ZIP" && sudo unzip -o "$TFLINT_ZIP" -d /usr/local/bin; then
      cecho "green" "[TFLint] installation done."
    else
      cecho "red" "[TFLint] installation failed."
      rm -f "$TFLINT_ZIP"
      return 1
    fi
    rm -f "$TFLINT_ZIP"
  else
    cecho "yellow" "DRY-RUN: curl -fsSL $TFLINT_URL -o <tmp>.zip && sudo unzip -o <tmp>.zip -d /usr/local/bin"
  fi
fi
