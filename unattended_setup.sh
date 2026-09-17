#!/bin/bash

###
# AdeoTEK dotfiles unattended setup
#

# shellcheck disable=SC1091
#
# DESCRIPTION:
#   This script performs an unattended (non-interactive) setup of dotfiles and packages.
#   It automatically installs and configures the specified packages without user prompts.
#
# USAGE:
#   ./unattended_setup.sh [OPTIONS] [ACTION]
#   ./unattended_setup.sh ls                    # List all available packages
#   ./unattended_setup.sh --packages pkg1,pkg2 # Install specific packages
#
# ACTIONS:
#   ls                    List all available packages and exit
#   (default: init)       Perform the installation/setup process
#
# GLOBAL OPTIONS:
#   --packages <list>     Comma-separated list of packages to install/setup
#                         Example: --packages git,nvim,tmux,docker
#   -v, --verbose         Enable verbose output for debugging
#   --dry-run             Perform a dry run without making actual changes
#   -h, --help            Show help and exit
#
# AVAILABLE PACKAGES:
#   Run './unattended_setup.sh ls' or see _scripts/core/_options.sh for the
#   authoritative, always-current task list and tier arrays.
#
# PACKAGE GROUPS (from _options.sh arrays):
#   Minimal:        base-tools, git, yazi, zellij, zsh
#   Console-only:   fastfetch, glow, nodejs, onefetch
#   Console:        Minimal + Console-only
#   Console extras: ansible, aws-cli, bash, claude-code, docker, dotnet,
#                   gcp-cli, github-cli, golang, graphify, headroom, helm,
#                   herdr, hermes, homebrew, kubectl, lsp-servers, mise,
#                   nerd-fonts, nvim, oh-my-posh, opencode, playwright,
#                   powershell, rtk, rustup, starship, terraform, tmux,
#                   tools, uv
#   Desktop-only:   ghostty, zed
#   Desktop extras: Console extras + kitty, tabby, vscode, jetbrains-toolbox
#   Shell:          zsh (in Minimal)
#
# EXAMPLES:
#   # List all available packages
#   ./unattended_setup.sh ls
#
#   # Install minimal development environment
#   ./unattended_setup.sh --packages base-tools,git,yazi,zellij,zsh
#
#   # Install development environment with Docker and Node.js
#   ./unattended_setup.sh --packages git,nvim,docker,nodejs --verbose
#
#   # Install desktop environment
#   ./unattended_setup.sh --packages git,nvim,tmux,kitty,zed
#
# NOTES:
#   - The script requires root/sudo privileges for system package installations
#   - Some packages have default versions that will be installed automatically
#   - The script performs a system update before installing packages
#   - All configurations are applied using predefined settings optimized for development
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

# Process command line arguments
process_args "$@"

# Special case: list available packages
if [[ "$1" == "ls" ]]; then
  cecho "white" "Available packages:"
  aecho ALL_TASKS "- " "yellow" "white"
  exit 0
fi

# Help
if [[ "$HELP_REQUESTED" -eq 1 ]]; then
  cecho "white" "Usage: $0 [OPTIONS] [ACTION] (--packages <list> is required unless ACTION is 'ls' or -h is given)"
  cecho "white" "AdeoTEK dotfiles unattended setup"
  cecho "white" "Actions:"
  cecho "cyan" "  ls                List all available packages and exit"
  cecho "cyan" "  (default: init)   Perform the installation/setup process"
  cecho "white" "Options:"
  cecho "cyan" "  --packages <list> Comma-separated list of packages to install/setup"
  cecho "cyan" "  --dry-run         Perform a dry run without making actual changes"
  cecho "cyan" "  -h, --help        Show this help and exit"
  cecho "cyan" "  -v, --verbose     Enable verbose output for debugging"
  exit 0
fi

## Startup debug
cecho "blue" "Starting dotfiles unattended setup ($DFS_ACTION)..."
decho "magenta" "Current OS: $CURRENT_OS_ID"
decho "magenta" "dotfiles root path: $RDIR"
decho "magenta" "core scripts path: $CDIR"

# Validate required arguments
if [[ -z "${ARGS["packages"]}" ]]; then
  cecho "red" "ERROR: --packages argument is required!"
  cecho "white" "Usage: $0 --packages <package1,package2,...> [OPTIONS]"
  cecho "white" "Use '$0 ls' to list all available packages"
  exit 1
fi

# Parse package list once (split on commas and spaces; no per-loop trimming needed)
IFS=', ' read -ra parsed_packages <<< "${ARGS["packages"]}"

# Validate package names against known tasks
SELECTED_PACKAGES=()
for pkg in "${parsed_packages[@]}"
do
  [[ -z "$pkg" ]] && continue
  if [[ -z "${TASK_TYPES[$pkg]:-}" ]]; then
    cecho "red" "ERROR: Unknown package: [$pkg]!"
    cecho "white" "Use '$0 ls' to list all available packages"
    exit 1
  fi
  SELECTED_PACKAGES+=("$pkg")
done

if [[ "${#SELECTED_PACKAGES[@]}" -eq 0 ]]; then
  cecho "red" "ERROR: No valid packages found in package list!"
  cecho "white" "Use '$0 ls' to list all available packages"
  exit 1
fi

# Display selected packages in verbose mode
if [[ "$VV" -eq 1 ]]; then
  cecho "white" "The following packages will be installed/set up:"
  aecho SELECTED_PACKAGES "- " "yellow" "white"
fi

# System update (performed before package installations)
if [[ "$DRY_RUN" -ne "1" ]]; then
  source "$CDIR/system-update.sh"
else
  cecho "yellow" "Dry run mode enabled. System update will be skipped."
fi

# Main package processing loop
# Each package is processed individually using its corresponding install/setup script
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg_task_type="${TASK_TYPES["$pkg"]}"  # Get task type (install/setup)
  decho "magenta" "Processing $pkg ($pkg_task_type) with default settings"
  # shellcheck source=/dev/null
  source "$CDIR/$pkg-$pkg_task_type.sh"
done

## End
cecho "blue" "DONE!"
