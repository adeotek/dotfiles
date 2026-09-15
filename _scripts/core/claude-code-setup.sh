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
  "lua-lsp@claude-plugins-official"
  "context-checkpoint@adeotek-plugins"
)

# Install
source "$CDIR/claude-code-install.sh"

# Install Claude official marketplace
cecho "green" "Installing Claude official marketplace..."
if claude plugin marketplace list | grep -G "claude-plugins-official" >/dev/null; then
  cecho "green" "Claude official marketplace already added to [claude-code]. Updating it..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    claude plugin marketplace update claude-plugins-official
  else
    cecho "yellow" "DRY-RUN: claude plugin marketplace update claude-plugins-official"
  fi
else
  if [[ "$DRY_RUN" -ne "1" ]]; then
    cecho "cyan" "Adding Claude official marketplace to [claude-code]..."
    claude plugin marketplace add anthropics/claude-plugins-official
  else
    cecho "yellow" "DRY-RUN: claude plugin marketplace add anthropics/claude-plugins-official"
  fi
fi

# Install ADEOTEK marketplace
if claude plugin marketplace list | grep -G "adeotek-plugins" >/dev/null; then
  cecho "green" "ADEOTEK marketplace already added to [claude-code]. Updating it..."
  if [[ "$DRY_RUN" -ne "1" ]]; then
    claude plugin marketplace update adeotek-plugins
  else
    cecho "yellow" "DRY-RUN: claude plugin marketplace update adeotek-plugins"
  fi
else
  if [[ "$DRY_RUN" -ne "1" ]]; then
    cecho "cyan" "Adding ADEOTEK marketplace to [claude-code]..."
    claude plugin marketplace add adeotek/claude-code
  else
    cecho "yellow" "DRY-RUN: claude plugin marketplace add adeotek/claude-code"
  fi
fi

# Install plugins
for plugin in "${CLAUDECODE_PLUGINS[@]}"; do
  if claude plugin list | grep -G "$plugin" >/dev/null; then
    cecho "green" "[claude-code] Plugin $plugin already installed. Updating it..."
    if [[ "$DRY_RUN" -ne "1" ]]; then
      claude plugin update "$plugin"
    else
      cecho "yellow" "DRY-RUN: claude plugin update $plugin"
    fi
  else
    if [[ "$DRY_RUN" -ne "1" ]]; then
      cecho "cyan" "Installing [claude-code] plugin: $plugin..."
      claude plugin install "$plugin"
    else
      cecho "yellow" "DRY-RUN: claude plugin install $plugin"
    fi
  fi
done

# Install LSP servers
source "$CDIR/lsp-servers-install.sh"

# Install CLI tools
source "$CDIR/playwright-install.sh"

# Configure status line
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p ~/.claude
  if [ ! -f "$HOME/.claude/statusline-command.sh" ]; then
    if cp "$RDIR/claude-code/user-config/statusline-command.sh" ~/.claude/statusline-command.sh; then
      chmod +x ~/.claude/statusline-command.sh
      cecho "green" "Status line configured successfully."
    else
      cecho "red" "Failed to copy statusline-command.sh."
    fi
  else
    cecho "yellow" "Status line script already exists at ~/.claude/statusline-command.sh"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/claude-code/user-config/statusline-command.sh ~/.claude/statusline-command.sh (if not exists)"
  cecho "yellow" "DRY-RUN: chmod +x ~/.claude/statusline-command.sh"
fi

# Create global CLAUDE.md file if it doesn't exist
if [[ "$DRY_RUN" -ne "1" ]]; then
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
if [[ "$DRY_RUN" -ne "1" ]]; then
  SETTINGS_FILE="$HOME/.claude/settings.json"
  if [ -f "$SETTINGS_FILE" ]; then
    if command -v jq >/dev/null 2>&1 && \
       jq -s '.[0] * .[1]' "$SETTINGS_FILE" "$RDIR/claude-code/user-config/settings-part.json" > "$SETTINGS_FILE.tmp"; then
      mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
      cecho "green" "User settings patched successfully."
    else
      rm -f "$SETTINGS_FILE.tmp"
      cecho "red" "Failed to patch user settings (jq missing or merge failed)."
    fi
  else
    if cp "$RDIR/claude-code/user-config/settings-part.json" "$SETTINGS_FILE"; then
      cecho "green" "User settings file created at $SETTINGS_FILE"
    else
      cecho "red" "Failed to create user settings file at $SETTINGS_FILE"
    fi
  fi
else
  cecho "yellow" "DRY-RUN: Patch $HOME/.claude/settings.json with $RDIR/claude-code/user-config/settings-part.json using jq"
fi
