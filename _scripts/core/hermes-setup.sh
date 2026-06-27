#!/bin/bash

###
# Hermes Agent setup script
#
# Deploys Hermes configuration files to ~/.hermes/.
# Follows the same pattern as claude-code and opencode:
# - Copies config.yaml if it doesn't exist (first-time setup)
# - Otherwise, uses hermes config check to report status
# - Does NOT overwrite existing config to preserve local changes
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi

# Install
source "$CDIR/hermes-install.sh"

# Ensure Hermes config directory exists
if [ "$DRY_RUN" -ne "1" ]; then
  mkdir -p "$HOME/.hermes"
fi

if [[ "${ARGS["unattended"]}" -ne "1" ]]; then
  cecho "yellow" -n "Do you want to configure the Headroom proxy for Hermes? (y/N): "
  read -r HEADROOM_HERMES
  if [[ "$HEADROOM_HERMES" =~ ^[Yy]$ ]]; then
    # Configure Headroom proxy for Hermes
    # Hermes reads OPENAI_BASE_URL for the "main" provider and ANTHROPIC_BASE_URL
    # for Anthropic. These are already set globally by bash/zsh configs.
    # We also add them to ~/.hermes/.env as a fallback for isolated environments.
    HERMES_ENV="$HOME/.hermes/.env"
    if [ "$DRY_RUN" -ne "1" ]; then
      if [ -f "$HERMES_ENV" ]; then
        # Append proxy vars if not already present
        if ! grep -q "OPENAI_BASE_URL" "$HERMES_ENV" 2>/dev/null; then
          {
            echo ""
            echo "# Headroom LLM proxy"
            echo "OPENAI_BASE_URL=http://localhost:8787/v1"
            echo "ANTHROPIC_BASE_URL=http://localhost:8787"
          } >> "$HERMES_ENV"
          cecho "green" "Headroom proxy env vars appended to $HERMES_ENV"
        else
          cecho "yellow" "Headroom proxy env vars already present in $HERMES_ENV"
        fi
      else
        cat > "$HERMES_ENV" <<'EOF'
# Headroom LLM proxy — automatic context compression
OPENAI_BASE_URL=http://localhost:8787/v1
ANTHROPIC_BASE_URL=http://localhost:8787
EOF
        cecho "green" "Hermes .env created with Headroom proxy configuration at $HERMES_ENV"
      fi
    else
      cecho "yellow" "DRY-RUN: ensure Headroom proxy env vars in $HERMES_ENV"
    fi
  fi
fi

# Setup config.yaml
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.hermes/config.yaml" ]; then
    cp "$RDIR/hermes/config.yaml" "$HOME/.hermes/config.yaml"
    cecho "green" "Hermes config.yaml deployed to ~/.hermes/config.yaml"
    cecho "cyan" "Next: add your API keys to ~/.hermes/.env and run 'hermes setup'"
  else
    cecho "yellow" "Hermes config.yaml already exists — skipping. To update, compare with:"
    cecho "cyan" "  diff $RDIR/hermes/config.yaml $HOME/.hermes/config.yaml"
    if command -v hermes >/dev/null 2>&1; then
      hermes config check
    fi
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/config.yaml $HOME/.hermes/config.yaml (if not exists)"
fi

# Create .env template if missing
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.hermes/.env" ]; then
    cp "$RDIR/hermes/.env.template" "$HOME/.hermes/.env"
    cecho "green" "Hermes .env template created at ~/.hermes/.env"
  else
    cecho "yellow" "Hermes .env already exists — skipping"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/.env.template $HOME/.hermes/.env (if not exists)"
fi

cecho "green" "[hermes] setup complete. Headroom proxy is ready for Hermes Agent."
