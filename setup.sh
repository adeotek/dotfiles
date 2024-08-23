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
cecho "white" "Setup options:"
for key in "${MENU_OPTION_KEYS[@]}"
do
  if [ "$key" == "$DEFAULT_MENU_OPTION" ]; then
    cecho "yellow" " *[$key] ${MENU_OPTIONS[$key]}"
  else
    cecho "white" "  [$key] ${MENU_OPTIONS[$key]}"
  fi
done
cecho "yellow" -n "Please select setup mode (0-4) [2]: "
read SETUP_MODE
if [ -z "$SETUP_MODE" ]; then
  SETUP_MODE="$DEFAULT_MENU_OPTION"
fi
if [[ "$SETUP_MODE" == "c" || "$SETUP_MODE" == "C" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

if [[ "$SETUP_MODE" == "0" ]]; then
  SELECTED_PACKAGES=()
  for task in "${ALL_TASKS[@]}"
  do
    cecho "yellow" -n "Do you want to include the ["
    cecho "cyan" -n "$task"
    cecho "yellow" -n "] package? [y/N]: "
    read INCLUDE_TASK
    # read -p "Do you want to include the [$task] package? [y/N]: " INCLUDE_TASK
    if [[ "$INCLUDE_TASK" == "y" || "$INCLUDE_TASK" == "Y" ]]; then
      SELECTED_PACKAGES+=($task)
    fi
  done
else
  case $SETUP_MODE in
    1)
      SELECTED_PACKAGES=("${MINIMAL_TASKS[@]}")
      ;;
    2)
      cecho "yellow" "Do you want to include the extra packages? [y/N]"
      cecho "cyan" -n "-> [${CONSOLE_EXTRA_TASKS[@]}] "
      read INCLUDE_EXTRA
      if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
        SELECTED_PACKAGES=("${ALL_CONSOLE_TASKS[@]}")
      else
        SELECTED_PACKAGES=("${CONSOLE_TASKS[@]}")
      fi
      ;;
    3)
      cecho "yellow" "Do you want to include the extra packages? [y/N]"
      cecho "yellow" -n "-> [${DESKTOP_EXTRA_TASKS[@]}] "
      read INCLUDE_EXTRA
      if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
        SELECTED_PACKAGES+=("${ALL_DESKTOP_TASKS[@]}")
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

if [[ -z "${SELECTED_PACKAGES[@]}" ]]; then
  cecho "magenta" "No package selected. Operation cancelled!"
  exit 11
fi

cecho "white" "The following packages will be installed/set up:"
aecho SELECTED_PACKAGES "- " "yellow" "white"
cecho "yellow" -n "Please confirm package selection [Y/n]: "
read PACKAGE_SELECTION_CONFIRM
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
