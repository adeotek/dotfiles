#!/bin/bash

###
# tools setup script
###

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi

# Setup
cecho "cyan" "Stowing [tools]..."
if ! stow --version >/dev/null 2>&1; then
  install_package "stow" "stow --version"
fi

stow_check_command=$(get_stow_command "tools" "init" "-n -v")
decho "magenta" "$stow_check_command"
check_result=$(bash -c "$stow_check_command 2>&1")
if echo "$check_result" | grep -G "LINK: .tools" >/dev/null \
  || echo "$check_result" | grep -G "\* cannot stow .*/tools/.* over existing target" >/dev/null; then
  if [ "$DFS_ACTION" == "remove" ]; then
    cecho "yellow" "Nothing to do. [tools] not stowed."
  else
    rename_dir_if_exists "$HOME/.tools"
    stow_command=$(get_stow_command "tools" "$DFS_ACTION")
    execute_command "$stow_command" "[tools] setup done."
  fi
else
  if [ "$DFS_ACTION" == "init" ]; then
    cecho "yellow" "Nothing to do. [tools] already stowed."
  else
    stow_command=$(get_stow_command "tools" "$DFS_ACTION")
    execute_command "$stow_command" "[tools] setup done."
  fi
fi
