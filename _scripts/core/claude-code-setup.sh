#!/bin/bash

###
# Claude Code setup script
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

declare CLAUDECODE_PLUGINS=(
  "frontend-design@claude-plugins-official"
  "code-review@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "playwright@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "superpowers@claude-plugins-official"
  "gopls-lsp@claude-plugins-official"
  "csharp-lsp@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "claude-code-setup@claude-plugins-official"
  "context7@claude-plugins-official"
  "ralph-loop@claude-plugins-official"
  "pyright-lsp@claude-plugins-official"
  "explanatory-output-style@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "playground@claude-plugins-official"
  "learning-output-style@claude-plugins-official"
  "microsoft-docs@claude-plugins-official"
  "terraform@claude-plugins-official"
  "lua-lsp@claude-plugins-official"
)

# Install
source "$CDIR/claude-code-install.sh"

# Install plugins
for plugin in "${CLAUDECODE_PLUGINS[@]}"; do
  if [ "$DRY_RUN" -ne "1" ]; then
    cecho "cyan" "Installing [claude-code] plugin: $plugin..."
    claude plugin install "$plugin"
  else
    cecho "yellow" "DRY-RUN: claude plugin install $plugin"
  fi
done

# Install LSP servers
if [ "$DRY_RUN" -ne "1" ]; then
  if command -v dotnet >/dev/null 2>&1; then
    dotnet tool install --global csharp-ls
    cecho "green" "[claude-code] .NET LSP server installed successfully."
  else
    cecho "yellow" "Skipping .NET LSP servers since [dotnet] is not available."
  fi

  if command -v go >/dev/null 2>&1; then
    go install golang.org/x/tools/gopls@latest
    cecho "green" "[claude-code] Go Lang LSP server installed successfully."
  else
    cecho "yellow" "Skipping Go Lang LSP servers since [go] is not available."
  fi

  if command -v npm >/dev/null 2>&1; then
    sudo npm install -g @vtsls/language-server typescript
    cecho "green" "[claude-code] JavaScript/TypeScript LSP servers installed successfully."
    sudo npm install -g pyright
    cecho "green" "[claude-code] Python LSP server installed successfully."
  else
    cecho "yellow" "Skipping JavaScript/TypeScript and Python LSP servers since [npm] is not available."
  fi
else
  cecho "yellow" "DRY-RUN: dotnet tool install --global csharp-ls"
  cecho "yellow" "DRY-RUN: go install golang.org/x/tools/gopls@latest"
  cecho "yellow" "DRY-RUN: sudo npm install -g @vtsls/language-server typescript"
  cecho "yellow" "DRY-RUN: sudo npm install -g pyright"
fi

case $CURRENT_OS_ID in
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo apt-get update
      sudo apt-get install -y lua-language-server
    else
      cecho "yellow" "DRY-RUN: sudo apt-get install -y lua-language-server"
    fi
    ;;
  fedora|redhat)
    source "$CDIR/homebrew-install.sh"
    install_package "lua-language-server" "brew list lua-language-server" "brew install lua-language-server"
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

# Install CLI tools
case $CURRENT_OS_ID in
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      if command -v npm >/dev/null 2>&1; then
        sudo npm install -g @playwright/cli@latest
        npx playwright install --with-deps chromium
        cecho "green" "[claude-code] Playwright CLI and dependencies installed successfully."
      else
        cecho "yellow" "Skipping CLI tools since [npm] is not available."
      fi
    else
      cecho "yellow" "DRY-RUN: sudo npm install -g @playwright/cli@latest"
      cecho "yellow" "DRY-RUN: npx playwright install --with-deps chromium"
    fi
    ;;
  fedora|redhat)
    if [ "$DRY_RUN" -ne "1" ]; then
      if command -v npm >/dev/null 2>&1; then
        # System deps Chromium requires on Fedora
        sudo dnf install -y nss atk at-spi2-atk gtk3 alsa-lib libdrm \
          libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm \
          libXScrnSaver cups-libs
        sudo npm install -g @playwright/cli@latest
        npx playwright install chromium
        cecho "green" "[claude-code] Playwright CLI and dependencies installed successfully."
      else
        cecho "yellow" "Skipping CLI tools since [npm] is not available."
      fi
    else
      cecho "yellow" "DRY-RUN: sudo dnf install -y nss atk at-spi2-atk gtk3 alsa-lib libdrm \\"
      cecho "yellow" "   libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm \\"
      cecho "yellow" "   libXScrnSaver cups-libs"
      cecho "yellow" "DRY-RUN: sudo npm install -g @playwright/cli@latest"
      cecho "yellow" "DRY-RUN: npx playwright install chromium"
    fi
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

# Configure status line
mkdir -p ~/.claude
if [ "$DRY_RUN" -ne "1" ]; then
  cp "$RDIR/claude-code/user-config/statusline.sh" ~/.claude/statusline.sh
  chmod +x ~/.claude/statusline.sh
  cecho "green" "Status line configured successfully."
else
  cecho "yellow" "DRY-RUN: cp $RDIR/claude-code/user-config/statusline.sh ~/.claude/statusline.sh"
  cecho "yellow" "DRY-RUN: chmod +x ~/.claude/statusline.sh"
fi

# Create global CLAUDE.md file if it doesn't exist
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.claude/CLAUDE.md" ]; then
    cp "$RDIR/claude-code/user-config/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    cecho "green" "Global CLAUDE.md file created at ~/.claude/CLAUDE.md"
  else
    cecho "yellow" "Global CLAUDE.md file already exists at ~/.claude/CLAUDE.md"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/claude-code/user-config/CLAUDE.md $HOME/.claude/CLAUDE.md"
fi

# Patch user settings
if [ "$DRY_RUN" -ne "1" ]; then
  SETTINGS_FILE="$HOME/.claude/settings.json"
  if [ -f "$SETTINGS_FILE" ]; then
    jq -s '.[0] * .[1]' "$SETTINGS_FILE" "$RDIR/claude-code/user-config/settings-part.json" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    cecho "green" "User settings patched successfully."
  else
    cp "$RDIR/claude-code/user-config/settings-part.json" "$SETTINGS_FILE"
    cecho "green" "User settings file created at $SETTINGS_FILE"
  fi
else
  cecho "yellow" "DRY-RUN: Patch $HOME/.claude/settings.json with $RDIR/claude-code/user-config/settings-part.json using jq"
fi
