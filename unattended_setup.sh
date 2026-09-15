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
#     bash                Bash shell configuration
#     git                 Git version control system
#     tmux                Terminal multiplexer
#     yazi                File manager
#
#   Console-only packages:
#     claude-code         Claude Code CLI and plugins
#     fastfetch           System information display
#     glow                Markdown renderer
#     golang              Go programming language (default: 1.26.5)
#     nodejs              Node.js runtime (default: 24)
#     onefetch            Git repository information display
#     tools               Auxiliary utility scripts
#
#   Console extra packages:
#     ansible             Automation tool
#     aws-cli             AWS command-line interface
#     docker              Container platform
#     dotnet              .NET SDK (default: 10.0)
#     github-cli          GitHub command-line interface
#     gcp-cli             Google Cloud Platform CLI
#     graphify            Codebase knowledge graph tool
#     headroom            Headroom LLM proxy
#     helm                Kubernetes package manager
#     herdr               herdr CLI
#     hermes              Hermes Agent
#     kubectl             Kubernetes CLI
#     lsp-servers         Language server protocol servers
#     mise                Polyglot tool version manager
#     nvim                Neovim text editor
#     opencode            OpenCode CLI
#     playwright          Playwright browser automation
#     powershell          PowerShell
#     rtk                 rtk CLI
#     rustup              Rust toolchain installer
#     uv                  Python package/tool manager
#     terraform           Infrastructure as Code tool
#     zellij              Terminal workspace manager
#
#   Desktop-only packages:
#     ghostty             Ghostty terminal emulator
#     zed                 Zed text editor
#     kitty               Terminal emulator
#     tabby               Terminal application
#     vscode              Visual Studio Code
#     jetbrains-toolbox   JetBrains development tools
#
#   Shell:
#     zsh                 Z shell
#
# PACKAGE GROUPS (for reference):
#   Minimal:    base-tools,bash,git,tmux,yazi
#   Console:    Minimal + claude-code,fastfetch,glow,golang,nodejs,onefetch,tools
#   Desktop:    Console + ghostty,zed
#   All:        Console + all extra packages + zsh
#
# EXAMPLES:
#   # List all available packages
#   ./unattended_setup.sh ls
#
#   # Install minimal development environment
#   ./unattended_setup.sh --packages base-tools,bash,git,tmux,yazi
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
if [[ -z "${SELECTED_PACKAGES[*]}" ]]; then
  cecho "red" "ERROR: No valid packages found in package list!"
  cecho "white" "Use '$0 ls' to list all available packages"
  exit 10
fi

# Validate package names against known tasks
for pkg in "${SELECTED_PACKAGES[@]}"
do
  pkg="${pkg// /}"
  [[ -z "$pkg" ]] && continue
  if [[ -z "${TASK_TYPES[$pkg]:-}" ]]; then
    cecho "red" "ERROR: Unknown package: [$pkg]!"
    cecho "white" "Use '$0 ls' to list all available packages"
    exit 10
  fi
done

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
  pkg="${pkg// /}"  # Trim whitespace from package name
  [[ -z "$pkg" ]] && continue
  pkg_task_type="${TASK_TYPES["$pkg"]}"  # Get task type (install/setup)
  decho "magenta" "Processing $pkg ($pkg_task_type) with default settings"
  # shellcheck source=/dev/null
  source "$CDIR/$pkg-$pkg_task_type.sh"
done

## End
cecho "blue" "DONE!"
