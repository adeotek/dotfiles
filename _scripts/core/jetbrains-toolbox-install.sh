#!/bin/bash

###
# JetBrains Toolbox install script
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
cecho "cyan" "Installing [jetbrains-toolbox]..."
if [[ ! -f "${HOME}/.local/bin/jetbrains-toolbox" && "$DRY_RUN" -ne "1" ]]; then
  mkdir -p "${HOME}/.local/bin"
fi

case $CURRENT_OS_ID in
  arch)
    execute_command "sudo pacman -S --noconfirm --needed fuse2 libxi libxrender libxtst mesa-utils fontconfig gtk3 tar dbus" "GUI dependencies installed."
    ;;
  debian|ubuntu|pop)
    execute_command "sudo apt-get install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session" "GUI dependencies installed."
    ;;
  fedora|redhat)
    execute_command "sudo dnf install -y fuse3-libs libXi libXrender libXtst mesa-demos fontconfig gtk3 tar dbus-x11" "GUI dependencies installed."
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

if [[ "$DRY_RUN" -ne "1" ]]; then
  TBA_URL="$(curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | jq -r '.TBA[0].downloads.linux.link')"
  if [[ -z "$TBA_URL" || "$TBA_URL" == "null" ]]; then
    cecho "red" "Failed to resolve JetBrains Toolbox download URL."
    return 1
  fi
  if ! (set -o pipefail; curl -fsSL "$TBA_URL" | tar xzf - \
      --directory="${HOME}/.local/bin" \
      --strip-components=1 \
      --wildcards -- '*/jetbrains-toolbox'); then
    cecho "red" "[jetbrains-toolbox] download/extraction failed."
    return 1
  fi
else
  cecho "yellow" "DRY-RUN: curl -fsSL <jetbrains-toolbox release> | tar xzf - --directory=${HOME}/.local/bin --strip-components=1 --wildcards -- */jetbrains-toolbox"
fi

# Create desktop entry
if [[ ! -f /usr/share/applications/jetbrains-toolbox-icon.png ]]; then
  execute_command "sudo wget https://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/jetbrains-toolbox-icon.png -O /usr/share/applications/jetbrains-toolbox-icon.png" "Icon downloaded."
fi
if [[ ! -f /usr/share/applications/jetbrains-toolbox.desktop ]]; then
  if [[ "$DRY_RUN" -ne "1" ]]; then
    sudo tee /usr/share/applications/jetbrains-toolbox.desktop <<EOF >/dev/null
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=${HOME}/.local/bin/jetbrains-toolbox
Icon=/usr/share/applications/jetbrains-toolbox-icon.png
EOF
  else
    cecho "yellow" "DRY-RUN: sudo tee /usr/share/applications/jetbrains-toolbox.desktop"
  fi
fi

if [[ "$DRY_RUN" -ne "1" ]]; then
  cecho "green" "[jetbrains-toolbox] installation done."
else
  cecho "yellow" "DRY-RUN: [jetbrains-toolbox] installation done."
fi
