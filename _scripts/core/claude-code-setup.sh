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

# Marketplaces, as "<marketplace-name>=<source>" (source is passed to 'marketplace add')
declare CLAUDECODE_MARKETPLACES=(
  "claude-plugins-official=anthropics/claude-plugins-official"
  "adeotek-plugins=adeotek/claude-code"
  "ponytail=DietrichGebert/ponytail"
)

declare CLAUDECODE_PLUGINS=(
  "claude-code-setup@claude-plugins-official"
  "claude-md-management@claude-plugins-official"
  "code-review@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "context-checkpoint@adeotek-plugins"
  "csharp-lsp@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "frontend-design@claude-plugins-official"
  "gopls-lsp@claude-plugins-official"
  "lua-lsp@claude-plugins-official"
  "microsoft-docs@claude-plugins-official"
  "playground@claude-plugins-official"
  "ponytail@ponytail"
  "pr-review-toolkit@claude-plugins-official"
  "pyright-lsp@claude-plugins-official"
  "security-guidance@claude-plugins-official"
  "skill-creator@claude-plugins-official"
  "superpowers@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
)

# Install
source "$CDIR/claude-code-install.sh"

if ! command -v claude >/dev/null 2>&1; then
  cecho "red" "[claude-code] 'claude' executable not found — skipping marketplace/plugin setup."
else
  # Install marketplaces
  for entry in "${CLAUDECODE_MARKETPLACES[@]}"; do
    mp_name="${entry%%=*}"
    mp_source="${entry#*=}"
    if claude plugin marketplace list | grep -G "$mp_name" >/dev/null; then
      cecho "green" "[claude-code] Marketplace $mp_name already added. Updating it..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        claude plugin marketplace update "$mp_name"
      else
        cecho "yellow" "DRY-RUN: claude plugin marketplace update $mp_name"
      fi
    else
      if [[ "$DRY_RUN" -ne "1" ]]; then
        cecho "cyan" "Adding [claude-code] marketplace: $mp_name ($mp_source)..."
        claude plugin marketplace add "$mp_source"
      else
        cecho "yellow" "DRY-RUN: claude plugin marketplace add $mp_source"
      fi
    fi
  done

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
fi

# Install LSP servers
source "$CDIR/lsp-servers-install.sh"

# Install CLI tools
source "$CDIR/playwright-install.sh"

# Configure status line
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$HOME/.claude"
  if [[ ! -f "$HOME/.claude/statusline-command.sh" ]]; then
    if cp "$RDIR/claude-code/user-config/statusline-command.sh" "$HOME/.claude/statusline-command.sh"; then
      chmod +x "$HOME/.claude/statusline-command.sh"
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
