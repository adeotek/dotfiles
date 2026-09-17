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
process_args "$@"

# Install
if [[ -z "${ARGS["font"]}" ]]; then
  TARGET_FONT="$OPT_NERDFONTS_DEFAULT_FONT"
else
  TARGET_FONT="${ARGS["font"]}"
fi

if [[ "$CURRENT_OS_ID" == "arch" && "$TARGET_FONT" == "CascadiaCode" ]]; then
  install_package "ttf-cascadia-code-nerd" "_"
else
  if [[ -z "${ARGS["version"]}" ]]; then
    TARGET_VERSION="$OPT_NERDFONTS_DEFAULT_VERSION"
  else
    TARGET_VERSION="${ARGS["version"]}"
  fi

  case $CURRENT_OS_ID in
  arch)
    install_package "fontconfig" "_"
    FONTS_DIR=".fonts"
    ;;
  debian|ubuntu|pop)
    install_package "fontconfig" "_"
    FONTS_DIR=".fonts"
    ;;
  fedora|redhat)
    install_package "fontconfig" "_"
    FONTS_DIR=".local/share/fonts"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
  esac

  SKIP_FONT_INST=""
  if [[ -d "$HOME/$FONTS_DIR/$TARGET_FONT" ]]; then
    if [[ $DFS_ACTION == "refresh" ]]; then
      ## Remove existing fonts
      if [[ "$DRY_RUN" -ne "1" ]]; then
        rm -rf -- "${HOME:?}/${FONTS_DIR:?}/${TARGET_FONT:?}"
      else
        cecho "yellow" "DRY-RUN: rm -rf -- ${HOME}/${FONTS_DIR}/${TARGET_FONT}"
      fi
    else
      SKIP_FONT_INST="1"
      cecho "yellow" "[$TARGET_FONT] fonts already installed!"
    fi
  else
    if [[ "$DRY_RUN" -ne "1" ]]; then
      mkdir -p "$HOME/$FONTS_DIR"
    fi
  fi
  if [[ -z "$SKIP_FONT_INST" ]]; then
    if [[ "$DRY_RUN" -ne "1" ]]; then
      ## Download fonts
      if wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v$TARGET_VERSION/$TARGET_FONT.zip" -O "$HOME/$TARGET_FONT.zip" \
        && unzip -q "$HOME/$TARGET_FONT.zip" -d "$HOME/$FONTS_DIR/$TARGET_FONT"; then
        rm -f "$HOME/$TARGET_FONT.zip"
      else
        cecho "red" "Failed to download/extract [$TARGET_FONT] Nerd Fonts."
        rm -f "$HOME/$TARGET_FONT.zip"
      fi
    else
      cecho "yellow" "DRY-RUN: wget https://github.com/ryanoasis/nerd-fonts/releases/download/v$TARGET_VERSION/$TARGET_FONT.zip -O $HOME/$TARGET_FONT.zip"
      cecho "yellow" "DRY-RUN: unzip $HOME/$TARGET_FONT.zip -d $HOME/$FONTS_DIR/$TARGET_FONT"
      cecho "yellow" "DRY-RUN: rm $HOME/$TARGET_FONT.zip"
    fi
  fi
fi

## Configure fonts
if [[ "$DRY_RUN" -ne "1" ]]; then
  fc-cache -fv
else
  cecho "yellow" "DRY-RUN: fc-cache -fv"
fi
