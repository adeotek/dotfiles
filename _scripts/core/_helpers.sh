#!/bin/bash

###
# Helpers for install/setup scripts
###

# shellcheck disable=SC2034,SC1091
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

function process_args() {
  # Only set the action from a leading non-flag argument; never clobber an
  # already-set DFS_ACTION (e.g. "refresh") with "init" when $1 is a flag.
  if [[ -n "$1" && "${1:0:1}" != "-" ]]; then
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
          exit 1
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
        exit 1
      ;;
    esac
    shift
  done
}

function cecho() {
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
    # shellcheck disable=SC2086  # intentional: empty args must vanish, "-n" must pass as flag
    echo ${args:+$args} "$@"
  else
    # shellcheck disable=SC2086
    echo -e ${args:+$args} "\e[${color_code}m${*}\e[0m"
  fi
}

function decho() {
  if [[ "$VV" -eq "1" ]]; then
    cecho "$@"
  fi
}

function aecho() {
  local sorted=0
  if [[ "$1" == "-s" ]]; then
    sorted=1
    shift
  fi
  local -n input=$1
  local prefix="$2"
  local color="$3"
  local prefix_color="$4"

  if [ -z "$prefix_color" ]; then
    prefix_color="$color"
  fi

  local items=("${input[@]}")
  if [[ "$sorted" -eq 1 ]]; then
    mapfile -t items < <(printf '%s\n' "${items[@]}" | sort)
  fi

  for val in "${items[@]}"
  do
    if [ ! -z "$prefix" ]; then
      cecho "$prefix_color" -n "$prefix"
    fi
    cecho "$color" "$val"
  done
}

# Interactive input helpers (single-keypress prompts)
IS_TTY=0
if [[ -t 0 && -t 1 ]]; then
  IS_TTY=1
fi

function read_key() {
  # Reads one keypress; prints a canonical key name or the literal character.
  # Arrow keys arrive as 3-byte CSI ("ESC [ X") or SS3 ("ESC O X", DECCKM)
  # sequences that can be split across TCP packets over SSH, so each
  # follow-up byte gets its own fresh timeout window (100ms; a lone Esc
  # costs that one delay, split bytes cost it only when actually split).
  # Ctrl+C keeps normal SIGINT behavior.
  # ponytail: 100ms per-byte window; tune up only if remote links still split arrows.
  local key seq="" c1 c2
  if ! IFS= read -rsn1 key; then
    echo "eof"
    return
  fi
  case "$key" in
    $'\x1b')
      if IFS= read -rsn1 -t 0.1 c1 && [[ "$c1" == "[" || "$c1" == "O" ]]; then
        if IFS= read -rsn1 -t 0.1 c2; then
          case "$c1$c2" in
            "[A"|"OA") echo "up"; return ;;
            "[B"|"OB") echo "down"; return ;;
            "[C"|"OC") echo "right"; return ;;
            "[D"|"OD") echo "left"; return ;;
          esac
        fi
      fi
      echo "esc"
      ;;
    ""|$'\r'|$'\n') echo "enter" ;;
    " ") echo "space" ;;
    $'\x7f'|$'\b') echo "backspace" ;;
    *) echo "$key" ;;
  esac
}

function read_yes_no() {
  # Usage: read_yes_no "prompt" "default(y|n)"
  # Single keypress on TTY, typed line otherwise. Sets REPLY_YN: y|n|esc.
  # q/Esc map to esc; callers decide whether esc means "no" or "cancel".
  local prompt="$1"
  local default="${2:-n}"
  local key line
  while true
  do
    cecho "yellow" -n "$prompt"
    if [[ "$IS_TTY" -eq 1 ]]; then
      key="$(read_key)"
      echo
    else
      key=""
      if ! IFS= read -r line; then
        REPLY_YN="esc"  # EOF: never interpret as yes
        return
      fi
      case "$line" in
        "") key="enter" ;;
        [yY]) key="y" ;;
        [nN]) key="n" ;;
        [qQ]) key="esc" ;;
        *) continue ;;
      esac
    fi
    case "$key" in
      y|Y) REPLY_YN="y"; return ;;
      n|N) REPLY_YN="n"; return ;;
      enter) REPLY_YN="$default"; return ;;
      esc|q|Q|eof) REPLY_YN="esc"; return ;;
    esac
  done
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

  if [[ "$DRY_RUN" -ne "1" ]]; then
    decho "magenta" "$command"
    if bash -c "$command"; then
      cecho "green" "$success_message"
    else
      cecho "red" "ERROR: command failed: $command"
      return 1
    fi
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
    decho "magenta" "Directory found and renamed to [$target$suffix]"
  else
    decho "magenta" "Directory [$target] not found!"
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
    decho "magenta" "File found and renamed to [$target$suffix]"
  else
    decho "magenta" "File [$target] not found!"
  fi
}

function increase_ulimit() {
  if [ $# -ne 1 ]; then
    cecho "red" "increase_ulimit() error: No target limit provided (Usage: increase_ulimit <target_limit>)"
    return
  fi

  if ! [[ "$1" =~ ^[0-9]+$ ]]; then
    cecho "red" "increase_ulimit() error: target limit must be a positive number"
    return
  fi

  local target_limit=$1
  # Get current soft limit
  local current_limit
  current_limit=$(ulimit -Sn)

  # "unlimited" (common default) is not numeric; it is already sufficient.
  if ! [[ "$current_limit" =~ ^[0-9]+$ ]]; then
    decho "yellow" "Current ulimit ($current_limit) is not numeric; assuming it is sufficient."
    return
  fi

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
  if [ -z "$check_command" ] || [ "$check_command" == "_" ]; then
    case $CURRENT_OS_ID in
      arch)
        check_command="pacman -Qi $package"
        ;;
      debian|ubuntu|pop)
        check_command="dpkg -s $package"
        ;;
      fedora|redhat)
        check_command="rpm -q $package"
        ;;
      *)
        cecho "red" "Unsupported OS: $CURRENT_OS_ID"
        exit 1
        ;;
    esac
  fi
  if $check_command >/dev/null 2>&1; then
    decho "yellow" "Package already installed. Updating it..."
  fi

  if [[ -z "$install_command" || "$install_command" == "_" ]]; then
   case $CURRENT_OS_ID in
      arch)
        install_command="sudo pacman -S --noconfirm --needed $package $additional_packages"
        ;;
      debian|ubuntu|pop)
        install_command="sudo apt-get install -y $package $additional_packages"
        ;;
      fedora|redhat)
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
      cecho "red" "ERROR: Invalid action: $stow_action!"
      exit 1
    ;;
  esac

  if [ -z "$extra_args" ]; then
    extra_args="$(get_vv)"
  fi

  echo "stow --dir=\"$RDIR\" --target=\"$HOME\" $extra_args $stow_arg $package"
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
  # Only a genuine conflict (an existing non-symlink target) requires renaming the target.
  # Matching stow's "LINK:" lines here also matches folded file links when merging into an
  # existing real directory, which wrongly renamed a mergeable target.
  if echo "$check_result" | grep -G "\* cannot stow .*/$package/.* over existing target" >/dev/null; then
    if [ "$stow_action" == "remove" ]; then
      cecho "yellow" "Nothing to do. [$package] not stowed."
      return
    fi

    if [[ "$DRY_RUN" -ne "1" ]]; then
      rename_dir_if_exists "$dir_rename"
      rename_file_if_exists "$file_rename"
    else
      if [ -n "$dir_rename" ]; then
        cecho "yellow" "DRY-RUN: mv $dir_rename $dir_rename-<timestamp>-bak (if exists)"
      fi
      if [ -n "$file_rename" ]; then
        cecho "yellow" "DRY-RUN: mv $file_rename $file_rename.<timestamp>.bak (if exists)"
      fi
    fi
  elif ! echo "$check_result" | grep -q "LINK:"; then
    if [ "$stow_action" == "init" ]; then
      cecho "yellow" "Nothing to do. [$package] already stowed."
      return
    fi
  fi

  cecho "cyan" "Running stow $stow_action for [$package]..."
  stow_command=$(get_stow_command "$package" "$stow_action")
  execute_command "$stow_command" "[$package] setup done."
}

# Symlink a single file from a package directory into $HOME (mirrors the stow layout).
# Unlike stow_package, only the given file is linked — the rest of the package dir stays untouched.
# Usage: symlink_package_file <package> <repo-relative-file-path> [init|refresh|remove]
function symlink_package_file() {
  local package="$1"
  local file="$2"
  local stow_action="$3"
  local source_file target_file target_dir

  if [[ -z "$stow_action" ]]; then
    stow_action="$DFS_ACTION"
  fi

  source_file="$RDIR/$package/$file"
  target_file="$HOME/$file"
  target_dir="$(dirname "$target_file")"

  case $stow_action in
    init|refresh)
      if [[ "$DRY_RUN" -ne "1" ]]; then
        mkdir -p "$target_dir"
      fi

      # Check if file is already correctly symlinked. A dangling or stale
      # symlink (e.g. the dotfiles checkout moved) must be relinked, not skipped.
      if [[ -L "$target_file" ]]; then
        if [[ "$(readlink -f "$target_file")" == "$(readlink -f "$source_file")" ]]; then
          cecho "yellow" "Nothing to do. File [$file] from package [$package] is already stowed (using symlink)."
          return
        fi
        # Stale symlink: drop it so the correct link can be created below.
        if [[ "$DRY_RUN" -ne "1" ]]; then
          rm -f "$target_file"
        fi
      elif [[ "$DRY_RUN" -ne "1" ]]; then
        rename_file_if_exists "$target_file"
      fi

      stow_command="ln -s \"$source_file\" \"$target_file\""
      execute_command "$stow_command" "File [$file] from package [$package] stowed (using symlink)."
    ;;
    remove)
      # Check if file is already symlinked
      if [[ ! -L "$target_file" ]]; then
        cecho "yellow" "Nothing to do. File [$file] from package [$package] is not stowed (using symlink)."
        return
      fi

      stow_command="rm \"$target_file\""
      execute_command "$stow_command" "File [$file] from package [$package] was unstowed (using symlink)."
    ;;
    *)
      echo "ERROR: Invalid action: $stow_action!"
      exit 1
    ;;
  esac
}

# Copy files from source dir to dest dir if they don't already exist
# Usage: copy_files_if_missing <src_dir> <dest_dir> <glob> [override]
function copy_files_if_missing() {
  local src_dir="$1"
  local dest_dir="$2"
  local glob="$3"
  local override="${4:-false}"
  local label
  label="$(basename "$src_dir")"
  if [[ "$DRY_RUN" -ne "1" ]]; then
    mkdir -p "$dest_dir"
  fi
  for src_file in "$src_dir"/$glob; do
    [[ -f "$src_file" ]] || continue
    local dest_file
    dest_file="$dest_dir/$(basename "$src_file")"
    if [[ "$DRY_RUN" -ne "1" ]]; then
      if [[ ! -f "$dest_file" ]] || [[ "$override" == true ]]; then
        cp "$src_file" "$dest_file"
        cecho "green" "$label $(basename "$src_file") copied to $dest_dir/"
      else
        cecho "yellow" "$label $(basename "$src_file") already exists at $dest_dir/"
      fi
    else
      cecho "yellow" "DRY-RUN: cp $src_file $dest_file (if not exists)"
    fi
  done
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
# NOTE: sourcing this file self-invokes process_args with the caller's "$@"
# (when the caller received any arguments), which is how setup.sh/update.sh and
# every sourced script honor --dry-run/--verbose without an explicit call.
# Explicit `process_args "$@"` calls elsewhere are redundant but harmless.
decho "white" "Loading _helpers.sh..."
if [ $# -ne 0 ]; then
  process_args "$@"
fi
