#!/bin/bash

###
# Headroom setup script
# Installs headroom-ai[all], deploys systemd user service, and configures the proxy
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
source "$CDIR/headroom-install.sh"

# --- Config directories ---
if [ "$DRY_RUN" -ne "1" ]; then
  mkdir -p "$HOME/.headroom"
  mkdir -p "$HOME/.config/headroom"
  mkdir -p "$HOME/.config/systemd/user"
fi

OVERRIDE_EXISTING=false
SERVICE_FILE="$HOME/.config/systemd/user/headroom-proxy.service"
if [ -f "$HOME/.config/headroom/proxy.env" ] || [ -f "$SERVICE_FILE" ]; then
  cecho "yellow" -n "Headroom config already exists. Do you want to overwrite it? (y/N):"
  read -r overwrite_config
  if [[ "$overwrite_config" =~ ^[Yy]$ ]]; then
    OVERRIDE_EXISTING=true
  fi
fi

# --- Deploy providers.env ---
if [ "$DRY_RUN" -ne "1" ]; then
  if [ -f "$HOME/.config/headroom/proxy.env" ]; then
    if [ "$OVERRIDE_EXISTING" = true ]; then
      cp "$RDIR/headroom/providers.env" "$HOME/.config/headroom/proxy.env"
      cecho "green" "Headroom provider config overwritten to ~/.config/headroom/proxy.env"
    else
      cecho "yellow" "Headroom provider config already exists at ~/.config/headroom/proxy.env"
    fi
  else
    cp "$RDIR/headroom/providers.env" "$HOME/.config/headroom/proxy.env"
    cecho "green" "Headroom provider config deployed to ~/.config/headroom/proxy.env"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/headroom/providers.env $HOME/.config/headroom/proxy.env (if not exists)"
fi

# --- Deploy models.json ---
if [ "$DRY_RUN" -ne "1" ]; then
  if [ -f "$HOME/.headroom/models.json" ]; then
    if [ "$OVERRIDE_EXISTING" = true ]; then
      cp "$RDIR/headroom/models.json" "$HOME/.headroom/models.json"
      cecho "green" "Headroom models.json overwritten to ~/.headroom/models.json"
    else
      cecho "yellow" "Headroom models.json already exists at ~/.headroom/models.json"
    fi
  else
    cp "$RDIR/headroom/models.json" "$HOME/.headroom/models.json"
    cecho "green" "Headroom models.json deployed to ~/.headroom/models.json"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/headroom/models.json $HOME/.headroom/models.json (if not exists)"
fi

# --- Deploy systemd service file ---
if [ "$DRY_RUN" -ne "1" ]; then
  if [ -f "$SERVICE_FILE" ]; then
    if [ "$OVERRIDE_EXISTING" = true ]; then
      cp "$RDIR/headroom/headroom-proxy.service" "$SERVICE_FILE"
      cecho "green" "Headroom systemd service overwritten to $SERVICE_FILE"
    else
      cecho "yellow" "headroom-proxy.service already exists at $SERVICE_FILE."
    fi
  else
    cp "$RDIR/headroom/headroom-proxy.service" "$SERVICE_FILE"
    cecho "green" "Headroom systemd service deployed to $SERVICE_FILE"
  fi  
else
  cecho "yellow" "DRY-RUN: cp $RDIR/headroom/headroom-proxy.service $SERVICE_FILE"
fi

# --- Reload systemd user daemon ---
if [ "$DRY_RUN" -ne "1" ]; then
  systemctl --user daemon-reload
  cecho "green" "systemd user daemon reloaded."
else
  cecho "yellow" "DRY-RUN: systemctl --user daemon-reload"
fi

# --- Enable lingering (service survives logout) ---
if [ "$DRY_RUN" -ne "1" ]; then
  if ! loginctl show-user "$USER" 2>/dev/null | grep -q "Linger=yes"; then
    loginctl enable-linger "$USER"
    cecho "green" "User lingering enabled — headroom-proxy will survive logout."
  else
    cecho "yellow" "User lingering already enabled."
  fi
else
  cecho "yellow" "DRY-RUN: loginctl enable-linger $USER"
fi

# --- Enable and start the service ---
if [ "$DRY_RUN" -ne "1" ]; then
  if systemctl --user is-enabled --quiet headroom-proxy.service; then
    cecho "yellow" "headroom-proxy.service is already enabled. It will be restarted."
    systemctl --user restart headroom-proxy.service
    cecho "green" "headroom-proxy.service restarted."
  else
    systemctl --user enable --now headroom-proxy.service
    cecho "green" "headroom-proxy.service enabled and started."
  fi
else
  cecho "yellow" "DRY-RUN: systemctl --user enable --now headroom-proxy.service"
fi

# --- Health check ---
if [ "$DRY_RUN" -ne "1" ]; then
  cecho "cyan" "Waiting for headroom proxy to become healthy..."
  retries=0
  max_retries=30
  while [ "$retries" -lt "$max_retries" ]; do
    if curl -sf http://localhost:8787/health >/dev/null 2>&1; then
      cecho "green" "headroom proxy is healthy on http://localhost:8787"
      break
    fi
    retries=$((retries + 1))
    sleep 1
  done
  if [ "$retries" -eq "$max_retries" ]; then
    cecho "red" "headroom proxy did not become healthy within ${max_retries}s. Check: systemctl --user status headroom-proxy"
  fi
else
  cecho "yellow" "DRY-RUN: curl -sf http://localhost:8787/health"
fi

cecho "green" "[headroom] setup complete."
