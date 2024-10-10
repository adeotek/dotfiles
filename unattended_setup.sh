#!/bin/bash

###
# AdeoTEK dotfiles unattended setup
###

# Init
declare -A ARGS=(["packages"]="")
if [[ -d "${0%/*}" ]]; then
  RDIR="$(cd "${0%/*}" && pwd)"
else
  RDIR="$PWD";
fi
CDIR="$RDIR/_scripts/core";

## Includes
source "$CDIR/_helpers.sh"
source "$CDIR/_options.sh"

if [[ "$1" == "ls" ]]; then
  cecho "white" "Available packages:"
  aecho ALL_TASKS "- " "yellow" "white"
  exit 0
fi

## Startup debug 
cecho "blue" "Starting dotfiles unatended setup ($DFS_ACTION)..."
decho "magenta" "Current OS: $CURRENT_OS_ID"
decho "magenta" "dotfiles root path: $RDIR"
decho "magenta" "core scripts path: $CDIR"

if [[ -z "${ARGS["packages"]}" ]]; then
  cecho "magenta" "No packages provided. Operation cancelled!"
  exit 10
fi

IFS=',' read -ra SELECTED_PACKAGES <<< "${ARGS["packages"]}"
if [[ -z "${SELECTED_PACKAGES[@]}" ]]; then
  cecho "magenta" "No packages provided. Operation cancelled!"
  exit 10
fi

if [[ "$VV" -eq 1 ]]; then
  cecho "white" "The following packages will be installed/set up:"
  aecho SELECTED_PACKAGES "- " "yellow" "white"
fi

# System update
source "$CDIR/system-update.sh"

# Main
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg=$(echo "$pkg" | xargs)  # Trim whitespace from $id
  pkg_task_type="${TASK_TYPES["$pkg"]}"
  if [[ -n "${TASK_UNATTENDED_ARGS[$pkg]}" ]]; then
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"" ${TASK_UNATTENDED_ARGS[$pkg]}"
    source "$CDIR/$pkg-$pkg_task_type.sh" "${TASK_UNATTENDED_ARGS[$pkg]}"
  else
    decho "magenta" "source ""$CDIR/$pkg-$pkg_task_type.sh"""
    source "$CDIR/$pkg-$pkg_task_type.sh"
  fi
done

## End
cecho "blue" "DONE!"
