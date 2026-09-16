#!/bin/bash

###
# AdeoTEK dotfiles setup
###

# shellcheck disable=SC1091

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
  if [[ "$key" == "$DEFAULT_MENU_OPTION" ]]; then
    cecho "yellow" " *[$key] ${MENU_OPTIONS[$key]}"
  else
    cecho "white" "  [$key] ${MENU_OPTIONS[$key]}"
  fi
done
cecho "yellow" -n "Please select setup mode (0-3, q) [$DEFAULT_MENU_OPTION]: "
while true
do
  read -r SETUP_MODE
  if [[ -z "$SETUP_MODE" ]]; then
    SETUP_MODE="$DEFAULT_MENU_OPTION"
  fi
  SETUP_MODE="${SETUP_MODE//[[:space:]]/}"
  if [[ "$SETUP_MODE" == "q" || "$SETUP_MODE" == "Q" ]]; then
    cecho "magenta" "Operation cancelled!"
    exit 10
  fi
  case $SETUP_MODE in
    0|1|2|3) break ;;
    *) cecho "red" "Invalid option selection: $SETUP_MODE" ;;
  esac
  cecho "yellow" -n "Please select setup mode (0-3, q) [$DEFAULT_MENU_OPTION]: "
done

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
    cecho "cyan" "[q] Cancel and exit"
    while true
    do
      cecho "yellow" -n "Please input the selected packages IDs separated by comma: "
      read -r TASKS_IDS
      if [[ "$TASKS_IDS" == "q" || "$TASKS_IDS" == "Q" ]]; then
        cecho "magenta" "Operation cancelled!"
        exit 10
      fi
      if [[ -z "$TASKS_IDS" ]]; then
        cecho "magenta" "No packages selected. Operation cancelled!"
        exit 10
      fi
      IFS=',' read -ra SELECTED_INDICES <<< "$TASKS_IDS"
      SELECTED_PACKAGES=()
      declare -A SEEN_IDS=()
      INVALID_ID=0
      for id in "${SELECTED_INDICES[@]}"
      do
        id="${id//[[:space:]]/}"  # Trim whitespace from $id
        if [[ -z "$id" ]]; then
          continue  # Ignore empty entries (e.g. trailing comma)
        fi
        if ! [[ "$id" =~ ^[0-9]+$ ]] || (( id >= ${#ALL_TASKS[@]} )); then
          cecho "red" "Invalid package id: [$id]"
          INVALID_ID=1
          break
        fi
        if [[ -n "${SEEN_IDS[$id]}" ]]; then
          continue  # Skip duplicate ids
        fi
        SEEN_IDS[$id]=1
        SELECTED_PACKAGES+=("${ALL_TASKS[$id]}")
      done
      if [[ "$INVALID_ID" -eq "1" ]]; then
        cecho "yellow" "Please try again."
        continue
      fi
      if [[ "${#SELECTED_PACKAGES[@]}" -eq 0 ]]; then
        cecho "red" "No valid package ids provided."
        continue
      fi
      break
    done
    ;;
  1)
    SELECTED_PACKAGES=("${MINIMAL_TASKS[@]}")
    ;;
  2)
    SELECTED_PACKAGES=("${CONSOLE_TASKS[@]}")
    cecho "yellow" "Extra packages (${#CONSOLE_EXTRA_TASKS[@]}):"
    mapfile -t EXTRA_LINES < <(printf '%s\n' "${CONSOLE_EXTRA_TASKS[@]}" | column -c 80)
    for line in "${EXTRA_LINES[@]}"
    do
      cecho "cyan" "$line"
    done
    cecho "yellow" -n "Do you want to include the extra packages? [y/N]: "
    read -r INCLUDE_EXTRA
    if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
      SELECTED_PACKAGES=("${ALL_CONSOLE_TASKS[@]}")
    fi
    ;;
  3)
    SELECTED_PACKAGES=("${DESKTOP_TASKS[@]}")
    cecho "yellow" "Extra packages (${#DESKTOP_EXTRA_TASKS[@]}):"
    mapfile -t EXTRA_LINES < <(printf '%s\n' "${DESKTOP_EXTRA_TASKS[@]}" | column -c 80)
    for line in "${EXTRA_LINES[@]}"
    do
      cecho "cyan" "$line"
    done
    cecho "yellow" -n "Do you want to include the extra packages? [y/N]: "
    read -r INCLUDE_EXTRA
    if [[ "$INCLUDE_EXTRA" == "y" || "$INCLUDE_EXTRA" == "Y" ]]; then
      SELECTED_PACKAGES=("${ALL_DESKTOP_TASKS[@]}")
    fi
    ;;
esac

if [[ -z "${SELECTED_PACKAGES[*]}" ]]; then
  cecho "magenta" "No package selected. Operation cancelled!"
  exit 10
fi

cecho "white" "The following packages will be installed/set up:"
aecho -s SELECTED_PACKAGES "- " "yellow" "white"
cecho "yellow" -n "Please confirm package selection [Y/n]: "
read -r PACKAGE_SELECTION_CONFIRM
if [[ "$PACKAGE_SELECTION_CONFIRM" != "y" && "$PACKAGE_SELECTION_CONFIRM" != "Y" && "$PACKAGE_SELECTION_CONFIRM" != "" ]]; then
  cecho "magenta" "Operation cancelled!"
  exit 10
fi

# System update
if [[ "$DRY_RUN" -ne "1" ]]; then
  source "$CDIR/system-update.sh"
else
  cecho "yellow" "Dry run mode enabled. System update will be skipped."
fi

# Main
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg_task_type="${TASK_TYPES["$pkg"]}"
  if [[ -n "${TASK_ARGS[$pkg]}" ]]; then
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"" ${TASK_ARGS[$pkg]}"
    # shellcheck disable=SC2086  # intentional word-split to pass multiple flags
    # shellcheck source=/dev/null
    source "$CDIR/$pkg-$pkg_task_type.sh" ${TASK_ARGS[$pkg]}
  else
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"""
    # shellcheck source=/dev/null
    source "$CDIR/$pkg-$pkg_task_type.sh"
  fi
done

## End
cecho "blue" "DONE!"
