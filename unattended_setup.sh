#!/bin/bash

###
# AdeoTEK dotfiles unattended setup
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
# REQUIRED OPTIONS:
#   --packages <list>     Comma-separated list of packages to install/setup
#                         Example: --packages git,nvim,tmux,docker
#
# GLOBAL OPTIONS:
#   -v, --verbose         Enable verbose output for debugging
#   --dry-run             Perform a dry run without making actual changes
#
# AVAILABLE PACKAGES:
#   Core/Minimal packages:
#     base-tools          Essential command-line tools
#     git                 Git version control system
#     yazi                File manager
#     bash                Bash shell configuration
#     tmux                Terminal multiplexer
#     nvim                Neovim text editor
#
#   Console-only packages:
#     dotnet              .NET SDK (default: 8.0)
#     neofetch            System information display
#     onefetch            Git repository information display
#
#   Desktop-only packages:
#     kitty               Terminal emulator
#     zed                 Zed text editor
#     hypr                Hyprland window manager
#
#   Extra packages (console/desktop):
#     github-cli          GitHub command-line interface
#     ansible             Automation tool
#     docker              Container platform
#     golang              Go programming language (default: 1.24.0)
#     powershell          PowerShell
#     python              Python programming language
#     nodejs              Node.js runtime (default: 22)
#     rustup              Rust toolchain installer
#     tabby               Terminal application (desktop only)
#     vscode              Visual Studio Code (desktop only)
#     jetbrains-toolbox   JetBrains development tools (desktop only)
#     gcp-cli             Google Cloud Platform CLI
#     terraform           Infrastructure as Code tool
#     zsh                 Z shell
#
# PACKAGE GROUPS (for reference):
#   Minimal:    base-tools,git,yazi,bash,tmux,nvim
#   Console:    Minimal + dotnet,neofetch,onefetch
#   Desktop:    Console + kitty,zed,hypr
#   All:        Desktop + all extra packages + zsh
#
# EXAMPLES:
#   # List all available packages
#   ./unattended_setup.sh ls
#
#   # Install minimal development environment
#   ./unattended_setup.sh --packages base-tools,git,nvim,tmux
#
#   # Install development environment with Docker and Node.js
#   ./unattended_setup.sh --packages git,nvim,docker,nodejs --verbose
#
#   # Install desktop environment
#   ./unattended_setup.sh --packages git,nvim,tmux,kitty,zed,hypr
#
# NOTES:
#   - The script requires root/sudo privileges for system package installations
#   - Some packages have default versions that will be installed automatically
#   - The script performs a system update before installing packages
#   - All configurations are applied using predefined settings optimized for development
###

# Init
declare -A ARGS=(["packages"]="" ["unattended"]="1")
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

## Startup debug 
cecho "blue" "Starting dotfiles unatended setup ($DFS_ACTION)..."
decho "magenta" "Current OS: $CURRENT_OS_ID"
decho "magenta" "dotfiles root path: $RDIR"
decho "magenta" "core scripts path: $CDIR"

# Validate required arguments
if [[ -z "${ARGS["packages"]}" ]]; then
  cecho "red" "ERROR: --packages argument is required!"
  cecho "white" "Usage: $0 --packages <package1,package2,...> [OPTIONS]"
  cecho "white" "Use '$0 ls' to list all available packages"
  exit 10
fi

# Parse and validate package list
IFS=',' read -ra SELECTED_PACKAGES <<< "${ARGS["packages"]}"
if [[ -z "${SELECTED_PACKAGES[@]}" ]]; then
  cecho "red" "ERROR: No valid packages found in package list!"
  cecho "white" "Use '$0 ls' to list all available packages"
  exit 10
fi

# Display selected packages in verbose mode
if [[ "$VV" -eq 1 ]]; then
  cecho "white" "The following packages will be installed/set up:"
  aecho SELECTED_PACKAGES "- " "yellow" "white"
fi

# System update (performed before package installations)
source "$CDIR/system-update.sh"

# Main package processing loop
# Each package is processed individually using its corresponding install/setup script
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg=$(echo "$pkg" | xargs)  # Trim whitespace from package name
  pkg_task_type="${TASK_TYPES["$pkg"]}"  # Get task type (install/setup)
  decho "magenta" "Processing $pkg ($pkg_task_type) with default settings"
  source "$CDIR/$pkg-$pkg_task_type.sh"
done

## End
cecho "blue" "DONE!"
