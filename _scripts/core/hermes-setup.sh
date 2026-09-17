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

# --- WSL systemd ---
if [[ "$DRY_RUN" -ne "1" ]]; then
  enable_wsl_systemd
fi

# Ensure Hermes config directory exists
if [[ "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "$HOME/.hermes"
fi

# Create .env template if missing (before the Headroom block, so the
# proxy vars below append to a complete template instead of replacing it)
HERMES_ENV="$HOME/.hermes/.env"
if [[ "$DRY_RUN" -ne "1" ]]; then
  if [[ ! -f "$HERMES_ENV" ]]; then
    if cp "$RDIR/hermes/.env.template" "$HERMES_ENV"; then
      chmod 600 "$HERMES_ENV"
      cecho "green" "Hermes .env template created at ~/.hermes/.env"
    else
      cecho "red" "Failed to deploy Hermes .env template."
    fi
  else
    cecho "yellow" "Hermes .env already exists — skipping"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/hermes/.env.template $HERMES_ENV (if not exists)"
fi

if [[ "${ARGS["unattended"]}" -ne "1" ]]; then
  read_yes_no "Do you want to configure the Headroom proxy for Hermes? (y/N): " "n"
  HEADROOM_HERMES="$REPLY_YN"
  if [[ "$HEADROOM_HERMES" == "y" ]]; then
    # Configure Headroom proxy for Hermes
    # Hermes reads OPENAI_BASE_URL for the "main" provider and ANTHROPIC_BASE_URL
    # for Anthropic. These are already set globally by bash/zsh configs.
    # We also add them to ~/.hermes/.env as a fallback for isolated environments.
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if [[ -f "$HERMES_ENV" ]]; then
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
        chmod 600 "$HERMES_ENV"
        cecho "green" "Hermes .env created with Headroom proxy configuration at $HERMES_ENV"
      fi
    else
      cecho "yellow" "DRY-RUN: ensure Headroom proxy env vars in $HERMES_ENV"
    fi
  fi
fi

# Setup config.yaml
if [[ "$DRY_RUN" -ne "1" ]]; then
  if [[ ! -f "$HOME/.hermes/config.yaml" ]]; then
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

# --- Deploy systemd user units ---
copy_files_if_missing "$RDIR/hermes/.config/systemd/user" "$HOME/.config/systemd/user" "*.service"
copy_files_if_missing "$RDIR/hermes/.config/systemd/user" "$HOME/.config/systemd/user" "*.timer"

# --- Deploy support scripts and assets ---
copy_files_if_missing "$RDIR/hermes/.hermes/scripts" "$HOME/.hermes/scripts" "*.sh"
if [[ "$DRY_RUN" -ne "1" ]]; then
  chmod +x "$HOME/.hermes/scripts"/*.sh 2>/dev/null || true
fi
copy_files_if_missing "$RDIR/hermes/.hermes" "$HOME/.hermes" "SOUL.md"
if [[ -d "$RDIR/hermes/.hermes/profiles" ]]; then
  for profile_dir in "$RDIR/hermes/.hermes/profiles"/*/; do
    [[ -d "$profile_dir" ]] || continue
    copy_files_if_missing "$profile_dir" "$HOME/.hermes/profiles/$(basename "$profile_dir")" "*"
  done
fi

# --- Reload systemd user daemon ---
if [[ "$DRY_RUN" -ne "1" ]]; then
  if [[ "$IF_WSL2" == "1" && ! -d /run/systemd/system ]]; then
    cecho "yellow" "WARNING: systemd is not running in this WSL2 session yet. Edit /etc/wsl.conf ([boot] systemd=true), run 'wsl --shutdown' from Windows, reopen, and re-run this setup to activate the Hermes units."
  elif systemctl --user daemon-reload; then
    cecho "green" "systemd user daemon reloaded."
  else
    cecho "red" "Failed to reload systemd user daemon (is a systemd user session available?)."
  fi
else
  cecho "yellow" "DRY-RUN: systemctl --user daemon-reload"
fi

if [[ "${HEADROOM_HERMES:-}" =~ ^[Yy]$ ]]; then
  cecho "green" "[hermes] setup complete. Headroom proxy is ready for Hermes Agent."
else
  cecho "green" "[hermes] setup complete."
fi
