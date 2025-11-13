#!/bin/bash

###
# AWS CLI install script
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
# TODO: implement upgrade in the upgrade.sh script
if [ "$DRY_RUN" -ne "1" ]; then
  case $CURRENT_OS_ID in
    debian|ubuntu|pop)
      sudo apt-get install -y unzip
      ;;
    fedora|redhat)
      sudo dnf remove -y awscli
      sudo dnf install -y unzip
      ;;
    *)
      cecho "red" "Unsupported OS: $CURRENT_OS_ID"
      exit 1
      ;;
  esac
fi

cecho "cyan" "Installing [aws-cli]..."
if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
  AWS_CLI_DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
else
  AWS_CLI_DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
fi

if aws --version >/dev/null 2>&1; then
  IS_AWS_CLI_INSTALLED=true
  decho "yellow" "Package already installed. Updating it..."
else
  IS_AWS_CLI_INSTALLED=false
fi

if [ "$DRY_RUN" -ne "1" ]; then
  decho "magenta" "curl ""$AWS_CLI_DOWNLOAD_URL"" -o ~/awscliv2.zip"
  curl "$AWS_CLI_DOWNLOAD_URL" -o ~/awscliv2.zip
  if [ -d ~/aws ]; then
    decho "magenta" "rm -rf ~/aws"
    rm -rf ~/aws
  fi
  decho "magenta" "unzip ~/awscliv2.zip"
  unzip ~/awscliv2.zip -d ~/aws
  if $IS_AWS_CLI_INSTALLED; then
    decho "magenta" "sudo ~/aws/install --update"
    sudo ~/aws/install --update
  else
    decho "magenta" "sudo ~/aws/install"
    sudo ~/aws/install
  fi
  decho "magenta" "rm -f ~/awscliv2.zip"
  rm -f ~/awscliv2.zip
else
  cecho "yellow" "DRY-RUN: curl ""$AWS_CLI_DOWNLOAD_URL"" -o ~/awscliv2.zip"
  cecho "yellow" "DRY-RUN: unzip ~/awscliv2.zip -d ~/aws"
  if $IS_AWS_CLI_INSTALLED; then
    cecho "yellow" "DRY-RUN: sudo ~/aws/install --update"
  else
    cecho "yellow" "DRY-RUN: sudo ~/aws/install"
  fi
  cecho "yellow" "DRY-RUN: rm -f ~/awscliv2.zip"
fi
