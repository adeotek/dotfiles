#!/bin/bash

###
# NodeJS install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["version"]="$OPT_NODEJS_DEFAULT_VERSION"
    ARGS["install-mode"]="source"
  else
    ARGS["version"]=""
    ARGS["install-mode"]=""
  fi
else
  declare -A ARGS=(["version"]="" ["install-mode"]="")
fi
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi
process_args "$@"

# Install
if [[ -z "${ARGS["version"]}" ]]; then
  cecho "yellow" -n "Please input the NodeJs version you want to install? [$OPT_NODEJS_DEFAULT_VERSION]: "
  read -r NODEJS_VERSION
  if [[ "$NODEJS_VERSION" == "" ]]; then
    NODEJS_VERSION="$OPT_NODEJS_DEFAULT_VERSION"
  fi
else
  NODEJS_VERSION="${ARGS["version"]}"
fi

NJS_INSTALL_MODE="${ARGS["install-mode"]}"
if [[ -z "$NJS_INSTALL_MODE" && "$CURRENT_ARCH" != "aarch64" ]]; then
  cecho "yellow" -n "Do you want to install NodeJs with Homebrew? [y/N]: "
  read -r INSTALL_MODE_CONFIRM
  if [[ "$INSTALL_MODE_CONFIRM" == "y" || "$INSTALL_MODE_CONFIRM" == "Y" ]]; then
    NJS_INSTALL_MODE="brew"
  fi
fi

if [[ "$NJS_INSTALL_MODE" == "brew" ]]; then
  install_package "node" "node -v" "brew install node@$NODEJS_VERSION"
  if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin* ]]; then
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if ! grep -qF "/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin" "$HOME/.bashrc" 2>/dev/null; then
        (echo; echo "export PATH=\"\$PATH:/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin\"") >> "$HOME/.bashrc"
      fi
      export PATH="$PATH:/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin"
    else
      cecho "yellow" "DRY-RUN: add /home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin to PATH in ~/.bashrc"
    fi
  fi
else
  cecho "cyan" "Installing [nodejs]..."
  case $CURRENT_OS_ID in
    arch)
      install_package "nodejs npm" "node -v"
      ;;
    debian|ubuntu|pop)
      if node -v >/dev/null 2>&1; then
        decho "yellow" "Package already installed. Updating it..."
      else
        if [[ "$DRY_RUN" -ne "1" ]]; then
          NODESOURCE_SETUP="$(mktemp)"
          if curl -fsSL "https://deb.nodesource.com/setup_${NODEJS_VERSION}.x" -o "$NODESOURCE_SETUP"; then
            sudo -E bash "$NODESOURCE_SETUP"
          else
            cecho "red" "Failed to download NodeSource setup script."
          fi
          rm -f "$NODESOURCE_SETUP"
        else
          cecho "yellow" "DRY-RUN: curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x -o <tmp> && sudo -E bash <tmp>"
        fi
      fi
      execute_command "sudo apt-get update && sudo apt-get install -y nodejs" "[nodejs] installation done."
      ;;
    fedora)
      if node -v >/dev/null 2>&1; then
        decho "yellow" "Package already installed. Updating it..."
      fi

      decho "yellow" "Removing old nodejs-${NODEJS_VERSION} package if exists..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        sudo dnf remove -y "nodejs-${NODEJS_VERSION}" || true
      else
        cecho "yellow" "DRY-RUN: sudo dnf remove -y nodejs-${NODEJS_VERSION}"
      fi
      execute_command "set -o pipefail && curl -fsSL https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | sudo bash -" "[nodejs] NodeSource repository added."
      execute_command "sudo dnf install -y nodejs" "[nodejs] installation done."
      ;;
    redhat)
      install_package "nodejs:$NODEJS_VERSION" "node -v" "sudo dnf module install -y nodejs:$NODEJS_VERSION"
      ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
      ;;
  esac
fi

if [[ "$NJS_INSTALL_MODE" != "brew" ]]; then
  execute_command "sudo npm install -g npm" "npm updated."
fi
