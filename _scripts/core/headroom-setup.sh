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

# --- Deploy providers.env (imperative copy, only if missing) ---
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.config/headroom/proxy.env" ]; then
    cp "$RDIR/headroom/providers.env" "$HOME/.config/headroom/proxy.env"
    cecho "green" "Headroom provider config deployed to ~/.config/headroom/proxy.env"
  else
    cecho "yellow" "Headroom provider config already exists at ~/.config/headroom/proxy.env"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/headroom/providers.env $HOME/.config/headroom/proxy.env (if not exists)"
fi

# --- Deploy models.json (imperative copy, only if missing) ---
if [ "$DRY_RUN" -ne "1" ]; then
  if [ ! -f "$HOME/.headroom/models.json" ]; then
    cp "$RDIR/headroom/models.json" "$HOME/.headroom/models.json"
    cecho "green" "Headroom models.json deployed to ~/.headroom/models.json"
  else
    cecho "yellow" "Headroom models.json already exists at ~/.headroom/models.json"
  fi
else
  cecho "yellow" "DRY-RUN: cp $RDIR/headroom/models.json $HOME/.headroom/models.json (if not exists)"
fi

# --- Deploy systemd service file (managed config: backup + replace) ---
SERVICE_FILE="$HOME/.config/systemd/user/headroom-proxy.service"
if [ "$DRY_RUN" -ne "1" ]; then
  rename_file_if_exists "$SERVICE_FILE"
  cp "$RDIR/headroom/headroom-proxy.service" "$SERVICE_FILE"
  cecho "green" "Headroom systemd service deployed to $SERVICE_FILE"
else
  cecho "yellow" "DRY-RUN: backup $SERVICE_FILE if exists, then cp $RDIR/headroom/headroom-proxy.service $SERVICE_FILE"
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
    decho "yellow" "User lingering already enabled."
  fi
else
  cecho "yellow" "DRY-RUN: loginctl enable-linger $USER"
fi

# --- Enable and start the service ---
if [ "$DRY_RUN" -ne "1" ]; then
  systemctl --user enable --now headroom-proxy.service
  cecho "green" "headroom-proxy.service enabled and started."
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
