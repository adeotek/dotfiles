#!/bin/bash

###
# NodeJS install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  # Reset first, so the --upgrade opt-in of a previous run cannot leak in
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["version"]="$OPT_NODEJS_DEFAULT_VERSION"
    ARGS["install-mode"]="source"
  else
    ARGS["version"]=""
    ARGS["install-mode"]=""
  fi
  ARGS["upgrade"]=""
else
  declare -A ARGS=(["version"]="" ["install-mode"]="" ["upgrade"]="")
fi
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi
process_args "$@"

# Helpers

function get_nodejs_version() {
  # Sets ARGS["version"] (from --version or an interactive prompt) and NODEJS_VERSION
  local requested_version="${ARGS["version"]}"
  if [[ -z "$requested_version" ]]; then
    cecho "yellow" -n "Please input the NodeJs version you want to install? [$OPT_NODEJS_DEFAULT_VERSION]: "
    read -r requested_version
    if [[ "$requested_version" == "" ]]; then
      requested_version="$OPT_NODEJS_DEFAULT_VERSION"
    fi
    ARGS["version"]="$requested_version"
  fi
  NODEJS_VERSION="$requested_version"
}

function nodejs_versions_match() {
  # Compares two versions: 26 and 26.4 both match 26.4.0, but 26.4 does not match 26.40.0
  local installed_version="${1#v}"
  local requested_version="${2#v}"
  if [[ -z "$installed_version" || -z "$requested_version" ]]; then
    return 1
  fi
  if [[ "$installed_version" == "$requested_version" || "$installed_version" == "$requested_version".* ]]; then
    return 0
  fi
  return 1
}

function nodejs_version_matches() {
  # True when the installed node matches the requested version
  local installed_version
  installed_version="$(node -v 2>/dev/null)"
  nodejs_versions_match "$installed_version" "$1"
}

# Guard: skip installation when node is already available.
# Only an explicit request coming from the setup flows (--upgrade, passed by
# setup.sh and unattended_setup.sh) asks for the version and upgrades on a
# mismatch; scripts that source this file as a dependency keep skipping.
if command -v node >/dev/null 2>&1; then
  NODEJS_CURRENT_VERSION="$(node -v 2>/dev/null)"
  if [[ "${ARGS["upgrade"]}" != "1" ]]; then
    cecho "yellow" "[nodejs] is already present. Skipping installation."
    return 0
  fi
  get_nodejs_version
  if nodejs_versions_match "$NODEJS_CURRENT_VERSION" "$NODEJS_VERSION"; then
    cecho "green" "[nodejs] $NODEJS_CURRENT_VERSION is already present and matches the requested version [$NODEJS_VERSION]. Skipping installation."
    return 0
  fi
  cecho "yellow" "[nodejs] $NODEJS_CURRENT_VERSION does not match the requested version [$NODEJS_VERSION]. Upgrading..."
fi

# Install
get_nodejs_version

NJS_INSTALL_MODE="${ARGS["install-mode"]}"
if [[ -z "$NJS_INSTALL_MODE" && "$CURRENT_ARCH" != "aarch64" ]]; then
  cecho "yellow" -n "Do you want to install NodeJs with Homebrew? [y/N]: "
  read -r INSTALL_MODE_CONFIRM
  if [[ "$INSTALL_MODE_CONFIRM" == "y" || "$INSTALL_MODE_CONFIRM" == "Y" ]]; then
    NJS_INSTALL_MODE="brew"
  fi
fi

if [[ "$NJS_INSTALL_MODE" == "brew" ]]; then
  install_package "node" "node -v" "brew install node@$NODEJS_VERSION"
  if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin* ]]; then
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if ! grep -qF "/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin" "$HOME/.bashrc" 2>/dev/null; then
        (echo; echo "export PATH=\"\$PATH:/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin\"") >> "$HOME/.bashrc"
      fi
      export PATH="$PATH:/home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin"
    else
      cecho "yellow" "DRY-RUN: add /home/linuxbrew/.linuxbrew/opt/node@$NODEJS_VERSION/bin to PATH in ~/.bashrc"
    fi
  fi
else
  cecho "cyan" "Installing [nodejs]..."
  case $CURRENT_OS_ID in
    arch)
      install_package "nodejs npm" "node -v"
      ;;
    debian|ubuntu|pop)
      if nodejs_version_matches "$NODEJS_VERSION"; then
        decho "yellow" "Requested NodeJs version already installed. Updating it..."
      else
        if [[ "$DRY_RUN" -ne "1" ]]; then
          NODESOURCE_SETUP="$(mktemp)"
          if curl -fsSL "https://deb.nodesource.com/setup_${NODEJS_VERSION}.x" -o "$NODESOURCE_SETUP"; then
            sudo -E bash "$NODESOURCE_SETUP"
          else
            cecho "red" "Failed to download NodeSource setup script."
          fi
          rm -f "$NODESOURCE_SETUP"
        else
          cecho "yellow" "DRY-RUN: curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x -o <tmp> && sudo -E bash <tmp>"
        fi
      fi
      execute_command "sudo apt-get update && sudo apt-get install -y nodejs" "[nodejs] installation done."
      ;;
    fedora)
      if node -v >/dev/null 2>&1; then
        decho "yellow" "Package already installed. Updating it..."
      fi

      decho "yellow" "Removing old nodejs-${NODEJS_VERSION} package if exists..."
      if [[ "$DRY_RUN" -ne "1" ]]; then
        sudo dnf remove -y "nodejs-${NODEJS_VERSION}" || true
      else
        cecho "yellow" "DRY-RUN: sudo dnf remove -y nodejs-${NODEJS_VERSION}"
      fi
      execute_command "set -o pipefail && curl -fsSL https://rpm.nodesource.com/setup_${NODEJS_VERSION}.x | sudo bash -" "[nodejs] NodeSource repository added."
      # --refresh: the repo file was just pointed at another major, and DNF would
      # otherwise answer from its cached (previous major) metadata and report
      # "already installed" instead of upgrading
      execute_command "sudo dnf --refresh install -y nodejs" "[nodejs] installation done."
      ;;
    redhat)
      install_package "nodejs:$NODEJS_VERSION" "node -v" "sudo dnf module install -y nodejs:$NODEJS_VERSION"
      ;;
    *)
      cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
      exit 1
      ;;
  esac
fi

if [[ "$NJS_INSTALL_MODE" != "brew" ]]; then
  # root's PATH may not see node (brew/tarball installs) — pass the user PATH through
  execute_command 'sudo env PATH="$PATH" npm install -g npm' "npm updated."
fi

# An explicit request must not report success on a silent no-op: verify the version
if [[ "${ARGS["upgrade"]}" == "1" && "$DRY_RUN" -ne "1" ]]; then
  NODEJS_INSTALLED_VERSION="$(node -v 2>/dev/null)"
  if nodejs_versions_match "$NODEJS_INSTALLED_VERSION" "$NODEJS_VERSION"; then
    cecho "green" "[nodejs] version check passed: $NODEJS_INSTALLED_VERSION (requested [$NODEJS_VERSION])."
  else
    cecho "red" "ERROR: [nodejs] version is [$NODEJS_INSTALLED_VERSION], expected [$NODEJS_VERSION]. The install did not take effect — check the package manager output above."
  fi
fi
