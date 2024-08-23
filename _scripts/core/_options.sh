#!/bin/bash

###
# Options and helpers for script composition
###

decho "white" "Loading _options.sh..."

MENU_OPTION_KEYS=("0" "1" "2" "3" "4" "c")
declare -A MENU_OPTIONS=(
  ["0"]="Manual selection"
  ["1"]="Minimal (base tools, git, yazi, bash, tmux, nvim)"
  ["2"]="Console (Minimal + dotnet, neofetch, zsh)"
  ["3"]="Desktop (Console + kitty, zed, hypr)"
  ["4"]="ALL"
  ["c"]="Cancel/Exit"
)

declare MINIMAL_TASKS=(
  "base-tools"
  "git"
  "yazi"
  "bash"
  "tmux"
  "nvim"
)

declare CONSOLE_TASKS=(
  "${MINIMAL_TASKS[@]}"
  "dotnet"
  "neofetch"
  "zsh"
)

declare DESKTOP_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "kitty"
  "zed"
  "hypr"
)

declare CONSOLE_EXTRA_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "ansible"
  "docker"
  "golang"
  "powershell"
  "python"
)

declare DESKTOP_EXTRA_TASKS=(
  "${DESKTOP_TASKS[@]}"
  "ansible"
  "docker"
  "golang"
  "powershell"
  "python"
  "tabby"
  "vscode"
)

declare ALL_TASKS=("${DESKTOP_EXTRA_TASKS[@]}")

declare -A TASK_TYPES=(
  ["base-tools"]="install"
  ["ansible"]="setup"
  ["bash"]="setup"
  ["docker"]="install"
  ["dotnet"]="install"
  ["git"]="setup"
  ["golang"]="install"
  ["homebrew"]="install"
  ["hypr"]="setup"
  ["kitty"]="setup"
  ["neodejs"]="install"
  ["neofetch"]="setup"
  ["nerd-fonts"]="install"
  ["nvim"]="setup"
  ["oh-my-posh"]="install"
  ["powershell"]="install"
  ["python"]="install"
  ["starship"]="install"
  ["tabby"]="setup"
  ["tmux"]="setup"
  ["vscode"]="install"
  ["yazi"]="setup"
  ["zed"]="setup"
  ["zsh"]="setup"
)

declare -A TASK_ARGS=(
  ["bash"]="--prompt oh-my-posh"
  ["zsh"]="--prompt starship"
)

get_setup_command() {
  local package="$1"
  echo "get_setup_command:package: $package"
  local task_type="${ALL_TASKS[$package]}"
  echo "get_setup_command:task_type: $task_type"

}