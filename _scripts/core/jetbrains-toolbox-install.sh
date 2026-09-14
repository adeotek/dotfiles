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
if [ -f "${HOME}/.local/bin/jetbrains-toolbox" ]; then
  decho "yellow" "Package already installed. Updating it..."
else
  if [ "$DRY_RUN" -ne "1" ]; then
    mkdir -p "${HOME}/.local/bin"
  fi
fi

case $CURRENT_OS_ID in
  arch)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo pacman -S --noconfirm --needed fuse2 libxi libxrender libxtst mesa-utils fontconfig gtk3 tar dbus
    else
      cecho "yellow" "DRY-RUN: sudo pacman -S --noconfirm --needed fuse2 libxi libxrender libxtst mesa-utils fontconfig gtk3 tar dbus"
    fi
    ;;
  debian|ubuntu|pop)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo apt-get install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session
    else
      cecho "yellow" "DRY-RUN: sudo apt-get install -y libfuse2 libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session"
    fi
    ;;
  fedora|redhat)
    if [ "$DRY_RUN" -ne "1" ]; then
      sudo dnf install -y fuse libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session
    else
      cecho "yellow" "DRY-RUN: sudo dnf install -y fuse libxi6 libxrender1 libxtst6 mesa-utils libfontconfig libgtk-3-bin tar dbus-user-session"
    fi
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac

if [ "$DRY_RUN" -ne "1" ]; then
  curl -sL \
      "$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
          | jq -r '.TBA[0].downloads.linux.link')" \
          | tar xzvf - \
              --directory="${HOME}/.local/bin" \
              --wildcards -- */jetbrains-toolbox \
              --strip-components=1
else
  cecho "yellow" "DRY-RUN: curl -sL <jetbrains-toolbox release> | tar xzvf - --directory=${HOME}/.local/bin"
fi

# Create desktop entry
if [ ! -f /usr/share/applications/jetbrains-toolbox-icon.png ]; then
  if [ "$DRY_RUN" -ne "1" ]; then
    sudo wget https://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/jetbrains-toolbox-icon.png -O /usr/share/applications/jetbrains-toolbox-icon.png
  else
    cecho "yellow" "DRY-RUN: sudo wget <jetbrains-toolbox-icon.png> -O /usr/share/applications/jetbrains-toolbox-icon.png"
  fi
fi
if [ ! -f /usr/share/applications/jetbrains-toolbox.desktop ]; then
  if [ "$DRY_RUN" -ne "1" ]; then
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

if [ "$DRY_RUN" -ne "1" ]; then
  cecho "green" "[jetbrains-toolbox] installation done."
else
  cecho "yellow" "DRY-RUN: [jetbrains-toolbox] installation done."
fi
