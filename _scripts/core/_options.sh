#!/bin/bash

###
# Options and helpers for script composition
###

decho "white" "Loading _options.sh..."

OPT_DOTNET_DEFAULT_VERSION="8.0"
OPT_GOLANG_DEFAULT_VERSION="1.23.2"
OPT_NERDFONTS_DEFAULT_VERSION="3.2.1"
case $CURRENT_OS_ID in
  arch)
    OPT_NODEJS_DEFAULT_VERSION="22"
    ;;
  debian)
    OPT_NODEJS_DEFAULT_VERSION="22"
    ;;
  ubuntu)
    OPT_NODEJS_DEFAULT_VERSION="22"
    ;;
  fedora|redhat|centos)
    OPT_NODEJS_DEFAULT_VERSION="22"
    ;;
  almalinux)
    OPT_NODEJS_DEFAULT_VERSION="20"
    ;;
  *)
    cecho "red" "ERROR: Unsupported OS: $CURRENT_OS_ID!"
    exit 1
    ;;
esac

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
  "zsh"
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
  ["zsh"]="--prompt oh-my-posh"
)

declare -A TASK_UNATTENDED_ARGS=(
  ["bash"]="--prompt oh-my-posh"
  ["dotnet"]="--version $OPT_DOTNET_DEFAULT_VERSION"
  ["golang"]="--version $OPT_GOLANG_DEFAULT_VERSION"
  ["nerd-fonts"]="--font CascadiaCode --version $OPT_NERDFONTS_DEFAULT_VERSION"
  ["nodejs"]="--version $OPT_NODEJS_DEFAULT_VERSION --install-mode source"
  ["zsh"]="--prompt oh-my-posh"
)
