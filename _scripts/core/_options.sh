#!/bin/bash

###
# Options and helpers for script composition
###

# shellcheck disable=SC2034,SC1091
decho "white" "Loading _options.sh..."

OPT_BASH_DEFAULT_PROMPT="oh-my-posh"
OPT_ZSH_DEFAULT_PROMPT="starship"
OPT_DOTNET_DEFAULT_VERSION="10.0"
OPT_GOLANG_DEFAULT_VERSION="1.26.5"
OPT_NERDFONTS_DEFAULT_VERSION="3.5.0"
OPT_NERDFONTS_DEFAULT_FONT="CascadiaCode"
OPT_NODEJS_DEFAULT_INSTALL_MODE="source"
OPT_NODEJS_DEFAULT_VERSION="24"

declare MINIMAL_TASKS=(
  "base-tools"
  "git"
  "zellij"
  "zsh"
)

declare CONSOLE_ONLY_TASKS=(
  "fastfetch"
  "glow"
  "nodejs"
  "onefetch"
  "yazi"
)

declare CONSOLE_TASKS=(
  "${MINIMAL_TASKS[@]}"
  "${CONSOLE_ONLY_TASKS[@]}"
)

declare CONSOLE_EXTRA_TASKS=(
  "ansible"
  "aws-cli"
  "bash"
  "claude-code"
  "docker"
  "dotnet"
  "gcp-cli"
  "github-cli"
  "golang"
  "graphify"
  "headroom"
  "helm"
  "herdr"
  "hermes"
  "homebrew"
  "kubectl"
  "lsp-servers"
  "mise"
  "nerd-fonts"
  "nvim"
  "oh-my-posh"
  "opencode"
  "pi"
  "playwright"
  "powershell"
  "rtk"
  "rustup"
  "starship"
  "terraform"
  "tmux"
  "tools"
  "uv"
)

declare ALL_CONSOLE_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "${CONSOLE_EXTRA_TASKS[@]}"
)

declare DESKTOP_ONLY_TASKS=(
  "ghostty"
  "zed"
)

declare DESKTOP_TASKS=(
  "${CONSOLE_TASKS[@]}"
  "${DESKTOP_ONLY_TASKS[@]}"
)

declare DESKTOP_EXTRA_TASKS=(
  "${CONSOLE_EXTRA_TASKS[@]}"
  "vscode"
  "jetbrains-toolbox"
)

declare ALL_DESKTOP_TASKS=(
  "${DESKTOP_TASKS[@]}"
  "${DESKTOP_EXTRA_TASKS[@]}"
  "kitty"
  "tabby"
)

declare ALL_TASKS=(
  "${MINIMAL_TASKS[@]}"
  "${CONSOLE_ONLY_TASKS[@]}"
  "${CONSOLE_EXTRA_TASKS[@]}"
  "${DESKTOP_ONLY_TASKS[@]}"
  "${DESKTOP_EXTRA_TASKS[@]}"
  "kitty"
  "tabby"
)
readarray -t ALL_TASKS < <(printf '%s\n' "${ALL_TASKS[@]}" | sort -u)

MENU_OPTION_KEYS=("0" "1" "2" "3" "q")
declare -A MENU_OPTIONS=(
  ["0"]="Manual selection"
  ["1"]="Minimal (${MINIMAL_TASKS[*]})"
  ["2"]="Console (${#CONSOLE_TASKS[@]} packages; extras opt-in)"
  ["3"]="Desktop ($(( ${#CONSOLE_TASKS[@]} + ${#DESKTOP_ONLY_TASKS[@]} )) packages; extras opt-in)"
  ["q"]="Cancel/Exit"
)

declare -A TASK_TYPES=(
  ["ansible"]="install"
  ["aws-cli"]="install"
  ["base-tools"]="install"
  ["bash"]="setup"
  ["claude-code"]="setup"
  ["docker"]="install"
  ["dotnet"]="install"
  ["gcp-cli"]="install"
  ["graphify"]="install"
  ["git"]="setup"
  ["github-cli"]="install"
  ["glow"]="install"
  ["golang"]="install"
  ["headroom"]="setup"
  ["helm"]="install"
  ["herdr"]="setup"
  ["hermes"]="setup"
  ["homebrew"]="install"
  ["ghostty"]="setup"
  ["kitty"]="setup"
  ["kubectl"]="install"
  ["lsp-servers"]="install"
  ["jetbrains-toolbox"]="setup"
  ["nodejs"]="install"
  ["fastfetch"]="setup"
  ["onefetch"]="install"
  ["mise"]="install"
  ["nerd-fonts"]="install"
  ["nvim"]="setup"
  ["oh-my-posh"]="setup"
  ["opencode"]="setup"
  ["pi"]="setup"
  ["playwright"]="install"
  ["powershell"]="install"
  ["uv"]="install"
  ["rtk"]="setup"
  ["rustup"]="install"
  ["starship"]="setup"
  ["tabby"]="setup"
  ["terraform"]="install"
  ["tmux"]="setup"
  ["tools"]="setup"
  ["vscode"]="install"
  ["yazi"]="setup"
  ["zed"]="setup"
  ["zellij"]="setup"
  ["zsh"]="setup"
)

declare -A TASK_ARGS=(
  ["bash"]="--prompt $OPT_BASH_DEFAULT_PROMPT"
  ["zsh"]="--prompt $OPT_ZSH_DEFAULT_PROMPT"
)
