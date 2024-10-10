#!/bin/bash

###
# AdeoTEK dotfiles setup
###

# Init
if [[ -d "${0%/*}" ]]; then
  RDIR="$(cd "${0%/*}" && pwd)"
else
  RDIR="$PWD";
fi
CDIR="$RDIR/_scripts/core";

## Includes
source "$CDIR/_helpers.sh"
source "$CDIR/_options.sh"

# Globals
DEFAULT_MENU_OPTION="0"

## Startup debug 
cecho "blue" "Starting dotfiles setup ($DFS_ACTION)..."
decho "magenta" "Current OS: $CURRENT_OS_ID"
decho "magenta" "dotfiles root path: $RDIR"
decho "magenta" "core scripts path: $CDIR"

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
cecho "yellow" -n "Please select setup mode (0-4) [$DEFAULT_MENU_OPTION]: "
read SETUP_MODE
if [ -z "$SETUP_MODE" ]; then
  SETUP_MODE="$DEFAULT_MENU_OPTION"
fi
if [[ "$SETUP_MODE" == "c" || "$SETUP_MODE" == "C" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

case $SETUP_MODE in
  0)
    SELECTED_PACKAGES=()
    cecho "yellow" "The available packages are:"
    for i in "${!ALL_TASKS[@]}"
    do
      if [[ $i -lt 10 ]]; then
        cecho "cyan" " [$i] ${ALL_TASKS[$i]}"
      else
        cecho "cyan" "[$i] ${ALL_TASKS[$i]}"
      fi
    done
    cecho "cyan" "[c] Cancel and exit"
    cecho "yellow" -n "Please input the selected packages IDs separated by comma: "
    read TASKS_IDS
    if [[ "$TASKS_IDS" == "c" || "$TASKS_IDS" == "C" ]]; then
      cecho "magenta" "Operation cancelled!"
      exit 10
    fi
    if [[ -z "$TASKS_IDS" ]]; then
      cecho "magenta" "No packages selected. Operation cancelled!"
      exit 10
    fi
    IFS=',' read -ra SELECTED_INDICES <<< "$TASKS_IDS"
    for id in "${SELECTED_INDICES[@]}"
    do
      id=$(echo "$id" | xargs)  # Trim whitespace from $id
      SELECTED_PACKAGES+=(${ALL_TASKS[$id]})
    done
    ;;
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
    ;;
  5)
    SELECTED_PACKAGES+=("${ALL_TASKS[@]}")
    ;;
  *)
    cecho "red" "Invalid option selection: $SETUP_MODE"
    exit 10
    ;;
esac

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

# System update
source "$CDIR/system-update.sh"

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
