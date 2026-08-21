#!/bin/bash

###
# LSP servers install script
# Installs language servers for languages present on the machine,
# for use by AI agents (Claude Code, OpenCode, etc.) and editors
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
source "$CDIR/nodejs-install.sh"

cecho "cyan" "Installing [lsp-servers]..."

# Format language servers (always installed): YAML, TOML, HTML, CSS, JSON
if [ "$DRY_RUN" -ne "1" ]; then
  sudo npm install -g yaml-language-server @taplo/cli vscode-langservers-extracted
  cecho "green" "[lsp-servers] YAML, TOML, HTML, CSS and JSON language servers installed successfully."
else
  cecho "yellow" "DRY-RUN: sudo npm install -g yaml-language-server @taplo/cli vscode-langservers-extracted"
fi

# Bash language server
if command -v bash >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo npm install -g bash-language-server
    cecho "green" "[lsp-servers] Bash language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g bash-language-server"
  fi
else
  cecho "yellow" "Skipping Bash language server since [bash] is not available."
fi

# JavaScript/TypeScript language server
if command -v node >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo npm install -g @vtsls/language-server typescript
    cecho "green" "[lsp-servers] JavaScript/TypeScript language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g @vtsls/language-server typescript"
  fi
else
  cecho "yellow" "Skipping JavaScript/TypeScript language server since [node] is not available."
fi

# Python language server
if command -v python3 >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo npm install -g pyright
    cecho "green" "[lsp-servers] Python language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g pyright"
  fi
else
  cecho "yellow" "Skipping Python language server since [python3] is not available."
fi

# Go language server
if command -v go >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    go install golang.org/x/tools/gopls@latest
    cecho "green" "[lsp-servers] Go language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: go install golang.org/x/tools/gopls@latest"
  fi
else
  cecho "yellow" "Skipping Go language server since [go] is not available."
fi

# .NET language server
if command -v dotnet >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    dotnet tool install --global csharp-ls
    cecho "green" "[lsp-servers] .NET language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: dotnet tool install --global csharp-ls"
  fi
else
  cecho "yellow" "Skipping .NET language server since [dotnet] is not available."
fi

# Rust language server
if command -v rustup >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    rustup component add rust-analyzer
    cecho "green" "[lsp-servers] Rust language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: rustup component add rust-analyzer"
  fi
else
  cecho "yellow" "Skipping Rust language server since [rustup] is not available."
fi

# PowerShell language server
if command -v pwsh >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    pwsh -Command "Install-Module -Name PowerShellEditorServices -Scope CurrentUser -Force"
    cecho "green" "[lsp-servers] PowerShell language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: pwsh -Command \"Install-Module -Name PowerShellEditorServices -Scope CurrentUser -Force\""
  fi
else
  cecho "yellow" "Skipping PowerShell language server since [pwsh] is not available."
fi

# Terraform language server
if command -v terraform >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    install_package "unzip" "command -v unzip"
    TERRAFORM_LS_VERSION=$(curl -s https://releases.hashicorp.com/terraform-ls/ | grep -oE 'terraform-ls/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d/ -f2)
    case $CURRENT_ARCH in
      x86_64)
        TERRAFORM_LS_ARCH="amd64"
        ;;
      aarch64)
        TERRAFORM_LS_ARCH="arm64"
        ;;
    esac
    curl -fsSL "https://releases.hashicorp.com/terraform-ls/$TERRAFORM_LS_VERSION/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TERRAFORM_LS_ARCH}.zip" -o /tmp/terraform-ls.zip
    sudo unzip -o /tmp/terraform-ls.zip -d /usr/local/bin
    rm -f /tmp/terraform-ls.zip
    cecho "green" "[lsp-servers] Terraform language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: curl -fsSL https://releases.hashicorp.com/terraform-ls/<latest>/terraform-ls_<latest>_linux_amd64.zip -o /tmp/terraform-ls.zip"
    cecho "yellow" "DRY-RUN: sudo unzip -o /tmp/terraform-ls.zip -d /usr/local/bin"
  fi
else
  cecho "yellow" "Skipping Terraform language server since [terraform] is not available."
fi

# Docker language server
if command -v docker >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo npm install -g dockerfile-language-server-nodejs
    cecho "green" "[lsp-servers] Dockerfile language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g dockerfile-language-server-nodejs"
  fi
else
  cecho "yellow" "Skipping Dockerfile language server since [docker] is not available."
fi

# Ansible language server
if command -v ansible >/dev/null 2>&1; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo npm install -g @ansible/ansible-language-server
    cecho "green" "[lsp-servers] Ansible language server installed successfully."
  else
    cecho "yellow" "DRY-RUN: sudo npm install -g @ansible/ansible-language-server"
  fi
else
  cecho "yellow" "Skipping Ansible language server since [ansible] is not available."
fi

# Lua language server
if command -v lua >/dev/null 2>&1 || command -v luajit >/dev/null 2>&1 || command -v nvim >/dev/null 2>&1; then
  case $CURRENT_OS_ID in
    arch)
      install_package "lua-language-server" "command -v lua-language-server"
      ;;
    debian|ubuntu|pop)
      if [ "$DRY_RUN" -ne "1" ]; then
        sudo apt-get update
        sudo apt-get install -y lua-language-server
        cecho "green" "[lsp-servers] Lua language server installed successfully."
      else
        cecho "yellow" "DRY-RUN: sudo apt-get install -y lua-language-server"
      fi
      ;;
    fedora|redhat)
      if [ "$DRY_RUN" -ne "1" ]; then
        source "$CDIR/homebrew-install.sh"
        install_package "lua-language-server" "brew list lua-language-server" "brew install lua-language-server"
      else
        cecho "yellow" "DRY-RUN: brew install lua-language-server"
      fi
      ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
      ;;
  esac
else
  cecho "yellow" "Skipping Lua language server since [lua]/[luajit]/[nvim] is not available."
fi
