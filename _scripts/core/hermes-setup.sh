#!/bin/bash

###
# Hermes Agent setup script
# Installs Hermes Agent and configures it to route LLM traffic through Headroom
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
source "$CDIR/hermes-install.sh"

# --- Ensure Hermes config directory exists ---
if [ "$DRY_RUN" -ne "1" ]; then
  mkdir -p "$HOME/.hermes"
fi

# --- Configure Headroom proxy for Hermes ---
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

# --- Deploy sample config.yaml (only if missing) ---
# This shows the user how to explicitly route Hermes through Headroom
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.hermes/config.yaml" ]; then
    cp "$RDIR/hermes/config.yaml" "$HOME/.hermes/config.yaml"
    cecho "green" "Hermes config.yaml deployed to ~/.hermes/config.yaml"
  else
    cecho "yellow" "Hermes config.yaml already exists at ~/.hermes/config.yaml"
    cecho "cyan" "Note: To use Headroom, ensure your provider is set to 'main' (uses OPENAI_BASE_URL) or 'anthropic' (uses ANTHROPIC_BASE_URL)."
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/config.yaml $HOME/.hermes/config.yaml (if not exists)"
fi

cecho "green" "[hermes] setup complete. Headroom proxy is ready for Hermes Agent."
