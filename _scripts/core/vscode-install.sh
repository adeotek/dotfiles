#!/bin/bash

###
# VS Code install script
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
    install_package "code" "code --version"
    ;;
  debian|ubuntu|pop)
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
      cecho "cyan" "Installing VS Code APT source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        sudo mkdir -p -m 755 /etc/apt/keyrings
        VSCODE_KEY_TMP="$(mktemp)"
        if curl -fsSL https://packages.microsoft.com/keys/microsoft.asc -o "$VSCODE_KEY_TMP" \
          && sudo gpg --dearmor -o /etc/apt/keyrings/microsoft-vscode.gpg "$VSCODE_KEY_TMP"; then
          echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft-vscode.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
          sudo apt-get update
        else
          cecho "red" "Failed to install VS Code APT key."
          return 1
        fi
        rm -f "$VSCODE_KEY_TMP"
      else
        cecho "yellow" "DRY-RUN: add Microsoft VS Code APT repository"
      fi
    fi
    install_package "code" "code --version"
    ;;
  fedora|redhat)
    if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
      cecho "cyan" "Installing VS Code YUM source..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        sudo tee /etc/yum.repos.d/vscode.repo <<'EOF' > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
      else
        cecho "yellow" "DRY-RUN: create /etc/yum.repos.d/vscode.repo"
      fi
    fi
    install_package "code" "code --version"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
