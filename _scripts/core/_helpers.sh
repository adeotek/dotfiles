#!/bin/bash

###
# Helpers for install/setup scripts
###

# Global system variables
CURRENT_OS_ID="$(awk -F= '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(awk -F= '/^VERSION_ID=/ {gsub(/"/, "", $2); print $2}' /etc/os-release)"
CURRENT_ARCH="$(uname -m)"
IF_WSL2="$(uname -r | grep -q "WSL2" && echo "1" || echo "0")"
CURRENT_CONFIG_DIR="$HOME/.config"

# Global variables and CLI arguments
VV="0"
DRY_RUN="0"
DFS_ACTION="init"

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

function increase_ulimit() {
  if [ $# -ne 1 ]; then
    cecho "red" "increase_ulimit() error: No target limit provided (Usage: adjust_ulimit <target_limit>)"
    return
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    cecho "red" "increase_ulimit() error: target limit must be a positive number"
    return
  fi

  local target_limit=$1
  # Get current soft limit
  local current_limit=$(ulimit -Sn)

  if [ "$current_limit" -lt "$target_limit" ]; then
    cecho "yellow" "Current ulimit ($current_limit) is below target ($target_limit). Increasing..."
    ulimit -n "$target_limit"
  else
    decho "yellow" "Current limit ($current_limit) is already sufficient"
  fi
}

function install_package() {
  local package="$1"
  local check_command="$2"
  local install_command="$3"
  local additional_packages="$4"

  cecho "cyan" "Installing [$package]..."
  if $check_command >/dev/null 2>&1; then
    decho "yellow" "Package already installed. Updating it..."
  fi

  if [[ -z "$install_command" || "$install_command" == "_" ]]; then
   case $CURRENT_OS_ID in
      arch)
        install_command="sudo pacman -S --noconfirm --needed $package $additional_packages"
        ;;
      debian|ubuntu|pop)
        install_command="sudo apt install -y $package $additional_packages"
        ;;
      fedora|redhat|centos|almalinux)
        install_command="sudo dnf install -y $package $additional_packages"
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

  echo "stow --dir="$RDIR" --target="$HOME" $extra_args $stow_arg $package"
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

  if [ ! -d "$CURRENT_CONFIG_DIR" ]; then
    mkdir -p "$CURRENT_CONFIG_DIR"
  fi

  if [ -z "$stow_action" ]; then
    stow_action="$DFS_ACTION"
  fi

  stow_check_command=$(get_stow_command "$package" "init" "-n -v")
  decho "magenta" "$stow_check_command"
  check_result=$(bash -c "$stow_check_command 2>&1")
  if echo "$check_result" | grep -G "LINK: .config/$package" >/dev/null \
    || echo "$check_result" | grep -G "\* cannot stow .*/$package/.* over existing target" >/dev/null; then
    if [ "$stow_action" == "remove" ]; then
      cecho "yellow" "Nothing to do. [$package] not stowed."
      return
    fi

    rename_dir_if_exists "$dir_rename"
    rename_file_if_exists "$file_rename"
  else
    if [ "$stow_action" == "init" ]; then
      cecho "yellow" "Nothing to do. [$package] already stowed."
      return
    fi
  fi

  if [ -z "$stow_action" ]; then
    cecho "red" "Missing stow action for package [$package]!"
    return
  fi
  cecho "cyan" "Running stow $stow_action for [$package]..."
  stow_command=$(get_stow_command "$package" "$stow_action")
  execute_command "$stow_command" "[$package] setup done."
}

function enable_wsl_systemd() {
  if [[ "$IF_WSL2" == "1" && ! -f /etc/wsl.conf ]]; then
    sudo tee -a /etc/wsl.conf <<EOF
[boot]
systemd=true
[user]
default=$USER
EOF
  fi
}

# Main
decho "white" "Loading _helpers.sh..."
if [ $# -ne 0 ]; then
  process_args "$@"
fi
