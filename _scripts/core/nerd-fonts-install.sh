#!/bin/bash

###
# Base tools install script
###

# Init
declare -A ARGS=(
  ["font"]=""
  ["version"]=""
)
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}/_scripts/core"
  else
    CDIR="$PWD/_scripts/core";
  fi
  source "$CDIR/_helpers.sh"
fi
process_args $@

# Install
if [ -z "${ARGS["font"]}" ]; then
  TARGET_FONT="CascadiaCode"
else
  TARGET_FONT="${ARGS["font"]}"
fi

if [ -z "${ARGS["version"]}" ]; then
  TARGET_VERSION="3.2.1"
else
  TARGET_VERSION="${ARGS["version"]}"
fi

case $CURRENT_OS_ID in
  arch)
    sudo pacman -S --noconfirm --needed fontconfig
    FONTS_DIR=".local/share/fonts"
    ;;
  debian|ubuntu)
    sudo apt install -y fontconfig
    FONTS_DIR=".fonts"
    ;;
  fedora)
    sudo dnf install -y fontconfig
    FONTS_DIR=".local/share/fonts"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac

SKIP_FONT_INST=""
if [ -d $HOME/$FONTS_DIR/$TARGET_FONT ]; then
  if [[ $ACTION == "refresh" ]]; then
    ## Remove existing fonts
    rm -rf $HOME/$FONTS_DIR/$TARGET_FONT
  else
    SKIP_FONT_INST="1"
    cecho "yellow" "[$TARGET_FONT] fonts already installed!"
  fi
else
  mkdir -p $HOME/$FONTS_DIR
fi
if [ -z "$SKIP_FONT_INST" ]; then
  ## Download fonts
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v$TARGET_VERSION/$TARGET_FONT.zip -O ~/$TARGET_FONT.zip
  ## Unpack fonts
  unzip ~/$TARGET_FONT.zip -d $HOME/$FONTS_DIR/$TARGET_FONT
  rm ~/$TARGET_FONT.zip
fi
## Configure fonts
fc-cache -fv

