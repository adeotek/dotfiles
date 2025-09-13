#!/bin/bash

###
# Base tools install script
###

# Init
if [[ "$(declare -p "ARGS" 2>/dev/null)" =~ "declare -A" ]]; then
  if [[ "${ARGS["unattended"]}" -eq "1" ]]; then
    ARGS["font"]="$OPT_NERDFONTS_DEFAULT_FONT"
    ARGS["version"]="$OPT_NERDFONTS_DEFAULT_VERSION"
  else
    ARGS["font"]=""
    ARGS["version"]=""
  fi
else
  declare -A ARGS=(
    ["font"]=""
    ["version"]=""
  )
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
process_args $@

# Install
if [ -z "${ARGS["font"]}" ]; then
  TARGET_FONT="CascadiaCode"
else
  TARGET_FONT="${ARGS["font"]}"
fi

if [[ "$CURRENT_OS_ID" == "arch" && "$TARGET_FONT" == "CascadiaCode" ]]; then
  sudo pacman -S --noconfirm --needed ttf-cascadia-code-nerd
else
  if [ -z "${ARGS["version"]}" ]; then
    TARGET_VERSION="$OPT_NERDFONTS_DEFAULT_VERSION"
  else
    TARGET_VERSION="${ARGS["version"]}"
  fi

  case $CURRENT_OS_ID in
  arch)
    sudo pacman -S --noconfirm --needed fontconfig
    FONTS_DIR=".fonts"
    ;;
  debian|ubuntu|pop)
    sudo apt-get install -y fontconfig
    FONTS_DIR=".fonts"
    ;;
  fedora|redhat|centos|almalinux)
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
    if [[ $DFS_ACTION == "refresh" ]]; then
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
fi

## Configure fonts
fc-cache -fv
