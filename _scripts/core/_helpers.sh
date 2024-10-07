#!/bin/bash

###
# Helpers for install/setup scripts
###

# Global system variables
CURRENT_OS_ID="$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(sed -n 's/^VERSION_ID=\(.*\)/\1/p' /etc/os-release)"
CURRENT_ARCH="$(uname -m)"

# Global variables and CLI arguments
VV="0"
DRY_RUN="0"
DFS_ACTION="init"
UNATTENDED="0"

# Global functions

function process_args {
  if [[ "${#1}" -eq 0 || "${1:0:1}" == "-" || "$1" == "" ]]; then
    DFS_ACTION="init"
  else
    DFS_ACTION="$1"
    shift
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      -v|--verbose)
        VV="1"
      ;;
      --dry-run)
        DRY_RUN="1"
      ;;
      --*)
        if [[ ! -v ARGS[${1:2}] ]]; then
          echo "ERROR: Invalid argument/flag: $1!"
          exit 2
        fi
        if [[ -z "$2" || "${2:0:2}" == "--" ]]; then
          ARGS[${1:2}]=1
        else
          ARGS[${1:2}]=$2
          shift
        fi
      ;;
      *)
        echo "ERROR[0]: Unknown argument/flag: $1!"
        exit 2
      ;;
    esac
    shift
  done

  decho "magenta" "process_args() -> DFS_ACTION: [$DFS_ACTION]"
}

function cecho {
  local color=$1
  shift

  case $1 in
    -n)
      local args="-n"
      shift
      ;;
    *) local args="";;
  esac
  
  case $color in
    "black") color_code="30";;
    "red") color_code="31";;
    "green") color_code="32";;
    "yellow") color_code="33";;
    "blue") color_code="34";;
    "magenta") color_code="35";;
    "cyan") color_code="36";;
    "white") color_code="37";;
    *) color_code="";;
  esac
  
  if [ -z "$color_code" ]; then
    echo $args "$@"
  else
    echo -e $args "\e[${color_code}m$@\e[0m"
  fi
}

function decho() {
  if [[ "$VV" -eq "1" ]]; then
    cecho "$@"
  fi
}

function aecho() {
  local -n input=$1
  local prefix="$2"
  local color="$3"
  local prefix_color="$4"

  if [ -z "$prefix_color" ]; then
    prefix_color="$color"
  fi

  for val in "${input[@]}"
  do
    if [ ! -z "$prefix" ]; then
      cecho "$prefix_color" -n "$prefix"
    fi
    cecho "$color" "$val"
  done
}

function is_associative_array() {
  [[ "$(declare -p "$1" 2>/dev/null)" =~ "declare -A" ]]
}

function get_vv() {
  if [[ "$VV" -eq "1" ]]; then
    echo "--verbose"
  else
    echo ""
  fi
}

function execute_command() {
  local command="$1"
  local success_message="$2"
 
  if [ "$DRY_RUN" -ne "1" ]; then
    decho "magenta" "$command"
    bash -c "$command"
    cecho "green" "$success_message"
  else
    cecho "yellow" "DRY-RUN: $command"
  fi
}

function rename_dir_if_exists() {
  local target="$1"
  local suffix="$2"

  if [ -z "$target" ]; then
    return 
  fi

  if [ -z "$suffix" ]; then
    suffix="-$(date +%Y%m%d%H%M%S)-bak"
  fi

  if [ -d "$target" ]; then
    mv "$target" "$target$suffix"
    decho "Directory found and renamed to [$target$suffix]"
  else
    decho "Directory [$target] not found!"
  fi
}

function rename_file_if_exists() {
  local target="$1"
  local suffix="$2"

  if [ -z "$target" ]; then
    return 
  fi

  if [ -z "$suffix" ]; then
    suffix=".$(date +%Y%m%d%H%M%S).bak"
  fi

  if [ -f "$target" ]; then
    mv "$target" "$target$suffix"
    decho "File found and renamed to [$target$suffix]"
  else
    decho "File [$target] not found!"
  fi
}

function install_package() {
  local package="$1"
  local check_command="$2"
  local install_command="$3"

  cecho "cyan" "Installing [$package]..."
  if $check_command >/dev/null 2>&1; then
    decho "yellow" "Package already installed. Updating it..."
  fi

  if [ -z "$install_command" ]; then
   case $CURRENT_OS_ID in
      arch)
        install_command="sudo pacman -S --noconfirm --needed $package"
        ;;
      debian|ubuntu)
        install_command="sudo apt install -y $package"
        ;;
      redhat|centos|almalinux)
        install_command="sudo dnf install -y $package"
        ;;
      *)
        cecho "red" "Unsupported OS: $CURRENT_OS_ID"
        exit 1
        ;;
    esac
  fi

  execute_command "$install_command" "[$package] installation done."
}

function get_stow_command() {
  local package="$1"
  local stow_action="$2"
  local extra_args="$3"
 
  case $stow_action in
    init)
      stow_arg="--stow"
    ;;
    remove)
      stow_arg="--delete"
    ;;
    refresh)
      stow_arg="--restow"
    ;;
    *)
      echo "echo ""ERROR: Invalid action: $stow_action!"""
      exit 1
    ;;
  esac

  if [ -z "$extra_args" ]; then
    extra_args="$(get_vv)"
  fi

  echo "stow --dir="$HOME/.dotfiles" --target="$HOME" $extra_args $stow_arg $package"
}

function stow_package() {
  local package="$1"
  local stow_action="$2"
  local dir_rename="$3"
  local file_rename="$4"

  cecho "cyan" "Stowing [$package]..."
  if ! stow --version >/dev/null 2>&1; then
    install_package "stow" "stow --version"
  fi

  if [ -z "$stow_action" ]; then
    stow_action="$DFS_ACTION"
  fi

  check_result=$(bash -c "$(get_stow_command "$package" "refresh" "-n -v") 2>&1")
  if echo "$check_result" | grep -q "UNLINK:" >/dev/null; then
    if [ "$stow_action" == "init" ]; then
      cecho "yellow" "Nothing to do. [$package] already stowed."
      return
    fi
  else
    if [ "$stow_action" == "remove" ]; then
      cecho "yellow" "Nothing to do. [$package] not stowed."
      return
    fi

    rename_dir_if_exists "$dir_rename"
    rename_file_if_exists "$file_rename"
  fi

  if [ -z "$stow_action" ]; then
    cecho "red" "Missing stow action for package [$package]!"
    return
  fi
  cecho "cyan" "Running stow $stow_action for [$package]..."
  stow_command=$(get_stow_command "$package" "$stow_action")
  execute_command "$stow_command" "[$package] setup done."
}

# Main
decho "white" "Loading _helpers.sh..."
if [ $# -ne 0 ]; then
  process_args "$@"
fi
