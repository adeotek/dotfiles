#!/bin/bash

###
# JetBrains Toolbox install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
cecho "cyan" "Installing [jetbrains-toolbox]..."
if [ -f ${HOME}/.local/bin/jetbrains-toolbox ]; then
  decho "yellow" "Package already installed. Updating it..."
else
  mkdir -p ${HOME}/.local/bin
fi

sudo pacman -S --noconfirm --needed fuse
set -e
set -o pipefail
curl -sL \
    $(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | jq -r '.TBA[0].downloads.linux.link') \
        | tar xzvf - \
            --directory="${HOME}/.local/bin" \
            --wildcards */jetbrains-toolbox \
            --strip-components=1


# Create desktop entry
if [ ! -f /usr/share/applications/jetbrains-toolbox-icon.png ]; then
  sudo wget https://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/jetbrains-toolbox-icon.png -O /usr/share/applications/jetbrains-toolbox-icon.png
fi
if [ ! -f /usr/share/applications/jetbrains-toolbox.desktop ]; then
  sudo tee /usr/share/applications/jetbrains-toolbox.desktop <<EOF >/dev/null
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=${HOME}/.local/bin/jetbrains-toolbox
Icon=/usr/share/applications/jetbrains-toolbox-icon.png
EOF
fi

cecho "green" "[jetbrains-toolbox] installation done."

