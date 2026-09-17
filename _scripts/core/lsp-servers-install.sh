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

# With Homebrew node, npm is not in root's PATH — use the user's npm instead
NPM_CMD="sudo npm"
if [[ "$NJS_INSTALL_MODE" == "brew" ]]; then
  NPM_CMD="npm"
fi

# All installs below are best-effort: one failing server must not stop the rest
# (execute_command reports failures and returns 1; || true keeps the script going)

# Format language servers (always installed): YAML, TOML, HTML, CSS, JSON
execute_command "$NPM_CMD install -g yaml-language-server @taplo/cli vscode-langservers-extracted" "[lsp-servers] YAML, TOML, HTML, CSS and JSON language servers installed successfully." || true

# Bash language server
if command -v bash >/dev/null 2>&1; then
  execute_command "$NPM_CMD install -g bash-language-server" "[lsp-servers] Bash language server installed successfully." || true
else
  cecho "yellow" "Skipping Bash language server since [bash] is not available."
fi

# JavaScript/TypeScript language server
if command -v node >/dev/null 2>&1; then
  execute_command "$NPM_CMD install -g @vtsls/language-server typescript" "[lsp-servers] JavaScript/TypeScript language server installed successfully." || true
else
  cecho "yellow" "Skipping JavaScript/TypeScript language server since [node] is not available."
fi

# Python language server
if command -v python3 >/dev/null 2>&1; then
  execute_command "$NPM_CMD install -g pyright" "[lsp-servers] Python language server installed successfully." || true
else
  cecho "yellow" "Skipping Python language server since [python3] is not available."
fi

# Go language server
if command -v go >/dev/null 2>&1; then
  execute_command "go install golang.org/x/tools/gopls@latest" "[lsp-servers] Go language server installed successfully." || true
else
  cecho "yellow" "Skipping Go language server since [go] is not available."
fi

# .NET language server
if command -v dotnet >/dev/null 2>&1; then
  execute_command "dotnet tool install --global csharp-ls || dotnet tool update --global csharp-ls" "[lsp-servers] .NET language server installed successfully." || true
else
  cecho "yellow" "Skipping .NET language server since [dotnet] is not available."
fi

# Rust language server
if command -v rustup >/dev/null 2>&1; then
  execute_command "rustup component add rust-analyzer" "[lsp-servers] Rust language server installed successfully." || true
else
  cecho "yellow" "Skipping Rust language server since [rustup] is not available."
fi

# PowerShell language server
if command -v pwsh >/dev/null 2>&1; then
  execute_command 'pwsh -Command "Install-Module -Name PowerShellEditorServices -Scope CurrentUser -Force"' "[lsp-servers] PowerShell language server installed successfully." || true
else
  cecho "yellow" "Skipping PowerShell language server since [pwsh] is not available."
fi

# Terraform language server
if command -v terraform >/dev/null 2>&1; then
  install_package "unzip" "command -v unzip"
  TERRAFORM_LS_VERSION="$(curl -fsSL https://releases.hashicorp.com/terraform-ls/ | grep -oE 'terraform-ls/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d/ -f2)"
  case $CURRENT_ARCH in
    x86_64)
      TERRAFORM_LS_ARCH="amd64"
      ;;
    aarch64)
      TERRAFORM_LS_ARCH="arm64"
      ;;
    *)
      TERRAFORM_LS_ARCH=""
      ;;
  esac
  if [[ -z "$TERRAFORM_LS_VERSION" || -z "$TERRAFORM_LS_ARCH" ]]; then
    cecho "red" "[lsp-servers] Could not resolve terraform-ls version or architecture — skipping."
  else
    if [[ "$DRY_RUN" -ne "1" ]]; then
      TERRAFORM_LS_ZIP="$(mktemp --suffix=.zip)"
      if curl -fsSL "https://releases.hashicorp.com/terraform-ls/$TERRAFORM_LS_VERSION/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TERRAFORM_LS_ARCH}.zip" -o "$TERRAFORM_LS_ZIP" \
        && sudo unzip -o "$TERRAFORM_LS_ZIP" -d /usr/local/bin; then
        cecho "green" "[lsp-servers] Terraform language server installed successfully."
      else
        cecho "red" "[lsp-servers] Terraform language server installation failed."
      fi
      rm -f "$TERRAFORM_LS_ZIP"
    else
      cecho "yellow" "DRY-RUN: curl -fsSL https://releases.hashicorp.com/terraform-ls/${TERRAFORM_LS_VERSION}/terraform-ls_${TERRAFORM_LS_VERSION}_linux_${TERRAFORM_LS_ARCH}.zip -o <tmp>.zip && sudo unzip -o <tmp>.zip -d /usr/local/bin"
    fi
  fi
else
  cecho "yellow" "Skipping Terraform language server since [terraform] is not available."
fi

# Docker language server
if command -v docker >/dev/null 2>&1; then
  execute_command "$NPM_CMD install -g dockerfile-language-server-nodejs" "[lsp-servers] Dockerfile language server installed successfully." || true
else
  cecho "yellow" "Skipping Dockerfile language server since [docker] is not available."
fi

# Ansible language server
if command -v ansible >/dev/null 2>&1; then
  execute_command "$NPM_CMD install -g @ansible/ansible-language-server" "[lsp-servers] Ansible language server installed successfully." || true
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
      execute_command "sudo apt-get update && sudo apt-get install -y lua-language-server" "[lsp-servers] Lua language server installed successfully." || true
      ;;
    fedora|redhat)
      source "$CDIR/homebrew-install.sh"
      install_package "lua-language-server" "brew list lua-language-server" "brew install lua-language-server"
      ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
      ;;
  esac
else
  cecho "yellow" "Skipping Lua language server since [lua]/[luajit]/[nvim] is not available."
fi
