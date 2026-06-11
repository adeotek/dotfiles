#!/bin/bash

###
# Headroom uninstall script
# Reverses headroom-setup.sh: stops the proxy service, removes deployed config,
# and uninstalls headroom-ai via uv.
###

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Uninstalls Headroom LLM proxy: stops and disables the systemd user service,
removes deployed configuration, and uninstalls headroom-ai via uv.

OPTIONS:
  -y, --yes       Skip confirmation prompts
  -v, --verbose   Verbose output
  --dry-run       Show what would be done without making changes
  -h, --help      Show this help message and exit

EXAMPLES:
  $(basename "$0") --dry-run
  $(basename "$0") -y
EOF
}

confirm_or_exit() {
  local prompt="$1"
  if [[ "$YES" == true ]]; then
    return 0
  fi
  cecho "yellow" -n "$prompt (y/N):"
  read -r answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    cecho "yellow" "Aborted."
    exit 10
  fi
}

remove_path() {
  local path="$1"
  local label="$2"

  if [[ ! -e "$path" ]]; then
    decho "yellow" "$label not found at $path — skipping."
    return 0
  fi

  if [[ "$DRY_RUN" -ne "1" ]]; then
    rm -rf "$path"
    cecho "green" "Removed $label ($path)."
  else
    cecho "yellow" "DRY-RUN: rm -rf $path"
  fi
}

# Parse arguments before sourcing helpers (they reset DRY_RUN/VV on load).
PARSE_DRY_RUN="0"
PARSE_VV="0"
YES=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -y|--yes)
      YES=true
      shift
      ;;
    -v|--verbose)
      PARSE_VV="1"
      shift
      ;;
    --dry-run)
      PARSE_DRY_RUN="1"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      usage
      exit 2
      ;;
  esac
done

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  set --
  source "$CDIR/_helpers.sh"
fi

DRY_RUN="$PARSE_DRY_RUN"
# shellcheck disable=SC2034 # consumed by decho in sourced _helpers.sh
VV="$PARSE_VV"
decho "white" "Verbose mode enabled."

systemd_user_available() {
  systemctl --user status >/dev/null 2>&1
}

SERVICE_NAME="headroom-proxy.service"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME"
HEADROOM_CONFIG_DIR="$HOME/.config/headroom"
HEADROOM_DATA_DIR="$HOME/.headroom"

cecho "cyan" "Uninstalling [headroom]..."

if [[ "$DRY_RUN" -ne "1" ]]; then
  confirm_or_exit "This will stop headroom-proxy, remove Headroom config, and uninstall headroom-ai. Continue?"
else
  cecho "yellow" "DRY-RUN: confirmation prompt skipped."
fi

# --- Stop and disable systemd user service ---
if command -v systemctl >/dev/null 2>&1 && systemd_user_available; then
  if systemctl --user list-unit-files "$SERVICE_NAME" >/dev/null 2>&1 || [[ -f "$SERVICE_FILE" ]]; then
    if systemctl --user is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
      if [[ "$DRY_RUN" -ne "1" ]]; then
        systemctl --user stop "$SERVICE_NAME"
        cecho "green" "$SERVICE_NAME stopped."
      else
        cecho "yellow" "DRY-RUN: systemctl --user stop $SERVICE_NAME"
      fi
    else
      decho "yellow" "$SERVICE_NAME is not running."
    fi

    if systemctl --user is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
      if [[ "$DRY_RUN" -ne "1" ]]; then
        systemctl --user disable "$SERVICE_NAME"
        cecho "green" "$SERVICE_NAME disabled."
      else
        cecho "yellow" "DRY-RUN: systemctl --user disable $SERVICE_NAME"
      fi
    else
      decho "yellow" "$SERVICE_NAME is not enabled."
    fi
  else
    decho "yellow" "systemd user unit $SERVICE_NAME not registered — skipping stop/disable."
  fi
elif command -v systemctl >/dev/null 2>&1; then
  decho "yellow" "systemd user session unavailable — skipping service stop/disable."
else
  cecho "yellow" "systemctl not found — skipping service stop/disable."
fi

# --- Remove systemd service file ---
remove_path "$SERVICE_FILE" "headroom-proxy systemd service file"

if command -v systemctl >/dev/null 2>&1 && systemd_user_available; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    systemctl --user daemon-reload
    cecho "green" "systemd user daemon reloaded."
  else
    cecho "yellow" "DRY-RUN: systemctl --user daemon-reload"
  fi
fi

# --- Remove deployed configuration ---
remove_path "$HEADROOM_CONFIG_DIR" "Headroom config directory"
remove_path "$HEADROOM_DATA_DIR" "Headroom data directory"

# --- Uninstall headroom-ai via uv ---
if command -v uv >/dev/null 2>&1; then
  if uv tool list 2>/dev/null | grep -q '^headroom-ai '; then
    if [[ "$DRY_RUN" -ne "1" ]]; then
      uv tool uninstall headroom-ai
      cecho "green" "headroom-ai uninstalled via uv."
    else
      cecho "yellow" "DRY-RUN: uv tool uninstall headroom-ai"
    fi
  elif command -v headroom >/dev/null 2>&1; then
    cecho "yellow" "headroom binary found but headroom-ai is not registered with uv — remove ~/.local/bin/headroom manually if needed."
  else
    decho "yellow" "headroom-ai is not installed via uv — skipping tool uninstall."
  fi
elif command -v headroom >/dev/null 2>&1; then
  cecho "yellow" "uv not found but headroom is on PATH — remove it manually if needed."
else
  decho "yellow" "headroom-ai is not installed — skipping tool uninstall."
fi

cecho "green" "[headroom] uninstall complete."
