#!/bin/bash

###
# Playwright CLI install script
# Installs @playwright/cli (playwright-cli) via npm and the Chromium browser
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
source "$CDIR/nodejs-install.sh"

cecho "cyan" "Installing [playwright]..."

case $CURRENT_OS_ID in
  arch)
    cecho "yellow" "[playwright] Arch Linux is not officially supported by Playwright. Installing without OS dependencies..."
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo npm install -g @playwright/cli@latest
      npx --yes playwright install chromium
    else
      cecho "yellow" "DRY-RUN: sudo npm install -g @playwright/cli@latest"
      cecho "yellow" "DRY-RUN: npx --yes playwright install chromium"
    fi
    ;;
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo npm install -g @playwright/cli@latest
      npx --yes playwright install --with-deps chromium
    else
      cecho "yellow" "DRY-RUN: sudo npm install -g @playwright/cli@latest"
      cecho "yellow" "DRY-RUN: npx --yes playwright install --with-deps chromium"
    fi
    ;;
  fedora|redhat)
    if [ "$DRY_RUN" -ne "1" ]; then
      # System deps Chromium requires on Fedora
      sudo dnf install -y nss atk at-spi2-atk gtk3 alsa-lib libdrm \
        libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm \
        libXScrnSaver cups-libs
      sudo npm install -g @playwright/cli@latest
      npx --yes playwright install chromium
    else
      cecho "yellow" "DRY-RUN: sudo dnf install -y nss atk at-spi2-atk gtk3 alsa-lib libdrm \\"
      cecho "yellow" "   libxkbcommon libXcomposite libXdamage libXrandr mesa-libgbm \\"
      cecho "yellow" "   libXScrnSaver cups-libs"
      cecho "yellow" "DRY-RUN: sudo npm install -g @playwright/cli@latest"
      cecho "yellow" "DRY-RUN: npx --yes playwright install chromium"
    fi
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac

# Verify
if [ "$DRY_RUN" -ne "1" ]; then
  if command -v playwright-cli >/dev/null 2>&1; then
    cecho "green" "[playwright] CLI and dependencies installed successfully."
  else
    cecho "red" "[playwright] installation failed — 'playwright-cli' command not found after install."
    exit 1
  fi
else
  cecho "yellow" "DRY-RUN: playwright-cli --version"
fi
