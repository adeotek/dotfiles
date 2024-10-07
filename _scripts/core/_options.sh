#!/bin/bash

###
# Options and helpers for script composition
###

decho "white" "Loading _options.sh..."

declare MINIMAL_TASKS=(
  "base-tools"
  "git"
  "yazi"
  "bash"
  "tmux"
  "nvim"
)

declare CONSOLE_ONLY_TASKS=(
  "dotnet"
  "neofetch"
  "zsh"
)

declare CONSOLE_TASKS=(
  "${MINIMAL_TASKS[@]}"
  "${CONSOLE_ONLY_TASKS[@]}"
)

declare DESKTOP_ONLY_TASKS=(
  "kitty"
  "zed"
  "hypr"
)

declare DESKTOP_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "${DESKTOP_ONLY_TASKS[@]}"
)

declare CONSOLE_EXTRA_TASKS=(
  "ansible"
  "docker"
  "golang"
  "powershell"
  "python"
  "nodejs"
  "rustup"
)

declare ALL_CONSOLE_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "${CONSOLE_EXTRA_TASKS[@]}"
)

declare DESKTOP_EXTRA_TASKS=(
  "ansible"
  "docker"
  "golang"
  "powershell"
  "python"
  "nodejs"
  "rustup"
  "tabby"
  "vscode"
  "jetbrains-toolbox"
)

declare ALL_DESKTOP_TASKS=(
  "${DESKTOP_TASKS[@]}"
  "${DESKTOP_EXTRA_TASKS[@]}"
)

declare ALL_TASKS=(
  "${MINIMAL_TASKS[@]}"
  "${CONSOLE_ONLY_TASKS[@]}"
  "${DESKTOP_ONLY_TASKS[@]}"
  "${DESKTOP_EXTRA_TASKS[@]}"
)

MENU_OPTION_KEYS=("0" "1" "2" "3" "4" "5" "c")
declare -A MENU_OPTIONS=(
  ["0"]="Manual selection"
  ["1"]="Minimal (${MINIMAL_TASKS[@]})"
  ["2"]="Console (Minimal + "${CONSOLE_ONLY_TASKS[@]}")"
  ["3"]="Desktop (Console + "${DESKTOP_ONLY_TASKS[@]}")"
  ["4"]="Interactive"
  ["5"]="All"
  ["c"]="Cancel/Exit"
)

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
  ["jetbrains-toolbox"]="setup"
  ["nodejs"]="install"
  ["neofetch"]="setup"
  ["nerd-fonts"]="install"
  ["nvim"]="setup"
  ["oh-my-posh"]="setup"
  ["powershell"]="install"
  ["python"]="install"
  ["rustup"]="install"
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

