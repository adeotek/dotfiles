#!/bin/bash

###
# Tabby install script
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
cecho "cyan" "Installing [tabby]..."
if [ -f /usr/bin/tabby ]; then
  decho "yellow" "Package already installed. Nothing to do."
else
  cecho "yellow" -n "Please specify the version to install [1.0.221]: "
  read -r TABBY_VERSION
  if [[ -z "$TABBY_VERSION" ]]; then
    TABBY_VERSION="1.0.221"
  fi

  if [[ "$CURRENT_ARCH" == "aarch64" ]]; then
    TABBY_ARCH="arm64"
  else
    TABBY_ARCH="x64"
  fi

  case $CURRENT_OS_ID in
    arch)
      tabby_ext="pacman"
      tabby_install_cmd=(sudo pacman -U --noconfirm --needed)
      ;;
    debian|ubuntu|pop)
      tabby_ext="deb"
      tabby_install_cmd=(sudo dpkg -i)
      ;;
    fedora|redhat)
      tabby_ext="rpm"
      tabby_install_cmd=(sudo dnf install -y)
      ;;
    *)
      cecho "red" "Unsupported OS: $CURRENT_OS_ID"
      return 1
      ;;
  esac

  tabby_package_file="tabby-$TABBY_VERSION-linux-$TABBY_ARCH.$tabby_ext"
  tabby_url="https://github.com/Eugeny/tabby/releases/download/v${TABBY_VERSION}/${tabby_package_file}"
  if [[ "$DRY_RUN" -ne "1" ]]; then
    if wget -q "$tabby_url" -O "$HOME/${tabby_package_file}" \
      && "${tabby_install_cmd[@]}" "$HOME/${tabby_package_file}"; then
      cecho "green" "[tabby] installation done."
    else
      cecho "red" "[tabby] installation failed."
    fi
    rm -f "$HOME/${tabby_package_file}"
  else
    cecho "yellow" "DRY-RUN: wget $tabby_url -O ~/${tabby_package_file} && ${tabby_install_cmd[*]} ~/${tabby_package_file}"
  fi
fi
