#!/bin/bash

###
# AdeoTEK dotfiles setup
###

# Init
if [[ -d "${0%/*}" ]]; then
  CDIR="${0%/*}/_scripts/core"
else
  CDIR="$PWD/_scripts/core";
fi

## Includes
source "$CDIR/_helpers.sh"
source "$CDIR/_options.sh"

# Globals
DEFAULT_MENU_OPTION="2"

## Startup debug 
cecho "blue" "Starting dotfiles setup ($ACTION)..."

# Menu
## Display main menu
echo "Setup options:"
for key in "${MENU_OPTION_KEYS[@]}"
do
  if [ "$key" == "$DEFAULT_MENU_OPTION" ]; then
    echo " *[$key] ${MENU_OPTIONS[$key]}"
  else
    echo "  [$key] ${MENU_OPTIONS[$key]}"
  fi
done
read -p "Please select setup mode (0-4) [2]: " SETUP_MODE
if [ -z "$SETUP_MODE" ]; then
  SETUP_MODE="$DEFAULT_MENU_OPTION"
fi
if [[ "$SETUP_MODE" == "c" || "$SETUP_MODE" == "C" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

if [[ "$SETUP_MODE" == "0" ]]; then
  echo "TODO: manual selection"
else
  case $SETUP_MODE in
    1)
      SELECTED_PACKAGES=("${MINIMAL_TASKS[@]}")
      ;;
    2)
      read -p "Do you want to include the extra packages (ansible, docker, golang, powershell, python, tabby, vscode)? [y/N]" INCLUDE_EXTRA
      if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
        SELECTED_PACKAGES=("${CONSOLE_EXTRA_TASKS[@]}")
      else
        SELECTED_PACKAGES=("${CONSOLE_TASKS[@]}")
      fi
      ;;
    3)
      read -p "Do you want to include the extra packages (ansible, docker, golang, powershell, python, tabby, vscode)? [y/N]" INCLUDE_EXTRA
      if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
        SELECTED_PACKAGES+=("${DESKTOP_EXTRA_TASKS[@]}")
      else
        SELECTED_PACKAGES+=("${DESKTOP_TASKS[@]}")
      fi
      ;;
    4)
      SELECTED_PACKAGES+=("${ALL_TASKS[@]}")
      ;;
    *)
      cecho "red" "Invalid option selection: $SETUP_MODE"
      exit 10
      ;;
  esac
fi

cecho "yellow" "The following packages will be installed/set up:"
aecho SELECTED_PACKAGES "- " "yellow" "white"
read -p "Please confirm package selection [Y/n]: " PACKAGE_SELECTION_CONFIRM
if [[ "$PACKAGE_SELECTION_CONFIRM" != "y" && "$PACKAGE_SELECTION_CONFIRM" != "Y" && "$PACKAGE_SELECTION_CONFIRM" != "" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

# Main
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg_task_type="${TASK_TYPES["$pkg"]}"
  if [[ -n "${TASK_ARGS[$pkg]}" ]]; then
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"" ${TASK_ARGS[$pkg]}"
    source "$CDIR/$pkg-$pkg_task_type.sh" "${TASK_ARGS[$pkg]}"
  else
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"""
    source "$CDIR/$pkg-$pkg_task_type.sh"
  fi
done

## End
cecho "blue" "DONE!"
