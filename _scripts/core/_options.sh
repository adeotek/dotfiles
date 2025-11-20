#!/bin/bash

###
# Options and helpers for script composition
###

decho "white" "Loading _options.sh..."

OPT_BASH_DEFAULT_PROMPT="oh-my-posh"
OPT_ZSH_DEFAULT_PROMPT="oh-my-posh"
OPT_DOTNET_DEFAULT_VERSION="10.0"
OPT_GOLANG_DEFAULT_VERSION="1.25.4"
OPT_NERDFONTS_DEFAULT_VERSION="3.4.0"
OPT_NERDFONTS_DEFAULT_FONT="CascadiaCode"
OPT_NODEJS_DEFAULT_INSTALL_MODE="source"
case $CURRENT_OS_ID in
  arch)
    OPT_NODEJS_DEFAULT_VERSION="24"
    ;;
  debian|ubuntu|pop)
    OPT_NODEJS_DEFAULT_VERSION="24"
    ;;
  fedora|redhat)
    OPT_NODEJS_DEFAULT_VERSION="22"
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
  "fastfetch"
  "onefetch"
  "glow"
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
  "github-cli"
  "ansible"
  "docker"
  "golang"
  "powershell"
  "python"
  "nodejs"
  "rustup"
  "aws-cli"
  "gcp-cli"
  "terraform"
)

declare ALL_CONSOLE_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "${CONSOLE_EXTRA_TASKS[@]}"
)

declare DESKTOP_EXTRA_TASKS=(
  "github-cli"
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
  "aws-cli"
  "gcp-cli"
  "terraform"
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
  ["ansible"]="install"
  ["bash"]="setup"
  ["docker"]="install"
  ["dotnet"]="install"
  ["git"]="setup"
  ["github-cli"]="install"
  ["glow"]="install"
  ["golang"]="install"
  ["aws-cli"]="install"
  ["gcp-cli"]="install"
  ["homebrew"]="install"
  ["hypr"]="setup"
  ["kitty"]="setup"
  ["jetbrains-toolbox"]="setup"
  ["nodejs"]="install"
  ["fastfetch"]="setup"
  ["onefetch"]="install"
  ["nerd-fonts"]="install"
  ["nvim"]="setup"
  ["oh-my-posh"]="setup"
  ["powershell"]="install"
  ["python"]="install"
  ["rustup"]="install"
  ["starship"]="install"
  ["tabby"]="setup"
  ["terraform"]="install"
  ["tmux"]="setup"
  ["vscode"]="install"
  ["yazi"]="setup"
  ["zed"]="setup"
  ["zsh"]="setup"
)

declare -A TASK_ARGS=(
  ["bash"]="--prompt $OPT_BASH_DEFAULT_PROMPT"
  ["zsh"]="--prompt $OPT_ZSH_DEFAULT_PROMPT"
)
