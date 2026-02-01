# AdeoTEK Dotfiles

A comprehensive, modular collection of Linux dotfiles and automated installation scripts for setting up development environments across multiple distributions.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Distributions](https://img.shields.io/badge/distros-Arch%20%7C%20Debian%20%7C%20Ubuntu%20%7C%20Fedora%20%7C%20RHEL-green.svg)](#supported-distributions)
[![Shell](https://img.shields.io/badge/shell-Bash%20%7C%20ZSH-orange.svg)](#shell-environments)
[![Packages](https://img.shields.io/badge/packages-30%2B-brightgreen.svg)](#available-packages)

## ✨ Features

- 🎯 **Modular Architecture** - 50+ individual installation scripts for granular control
- 🐧 **Multi-Distribution** - Supports Arch, Debian, Ubuntu, Pop!OS, Fedora, and RHEL
- 🔧 **GNU Stow** - Symlink-based configuration management
- ⚡ **Interactive & Unattended** - Both modes supported for flexibility
- 🚀 **Comprehensive Tools** - Development tools, CLI utilities, desktop applications, AI coding assistants
- 🎨 **Shell Configurations** - Bash and advanced ZSH configurations with Oh My Posh/Starship prompts
- 🔒 **WSL2 Support** - Special handling for Windows Subsystem for Linux
- 🧪 **Dry Run & Verbose Modes** - Test installations and debug with detailed output
- 📦 **Package Groups** - Predefined groups (Minimal, Console, Desktop) for quick setup

## 📦 What's Included

### Development Tools
- **Languages**: Node.js (v22/24), Python, Go (1.25.4), Rust, .NET SDK (10.0), PowerShell
- **Cloud/DevOps**: Docker, AWS CLI, GCP CLI, Terraform, Ansible
- **Editors**: Neovim (with custom config), Zed, VS Code, JetBrains Toolbox
- **AI/Code Assistants**: Claude Code, OpenCode

### CLI Utilities
- **Core**: git, tmux, fzf, ripgrep, bat, fd, eza, zoxide, yazi
- **System**: fastfetch, onefetch, glow, GitHub CLI
- **Package Managers**: Homebrew (Linux), Rustup

### Shell Environments
- **Bash**: Comprehensive configuration with Oh My Posh/Starship prompt support and tool integrations
- **ZSH**: Two configurations available (see zsh/README.md for details):
  - Standard config with Oh My Zsh plugin support
  - Standalone config with all features built-in (no plugin manager needed)

### Desktop Applications
- **Terminals**: Kitty, Tabby
- **Editors**: VS Code, Zed, JetBrains Toolbox
- **Window Managers**: Hyprland configuration

### Prompts & Themes
- Oh My Posh (with custom themes)
- Starship
- Custom ZSH prompt with git integration

## 🚀 Quick Start

### One-Line Installation

```bash
git clone https://github.com/adeotek/dotfiles.git ~/.dotfiles && ~/.dotfiles/setup.sh
```

### Step-by-Step Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/adeotek/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run the interactive setup:**
   ```bash
   ./setup.sh
   ```

3. **Select installation mode:**
   - **Manual selection** - Choose specific packages by ID
   - **Minimal** - Essential tools (base-tools, bash, git, tmux, yazi)
   - **Console** - Minimal + development tools (nodejs, dotnet, golang, fastfetch, onefetch, glow, claude-code, opencode)
   - **Desktop** - Console + desktop apps (kitty, zed, hypr)
   - **Interactive** - Prompted for each package individually
   - **All** - Everything including extra packages

### Unattended Installation

For automated setups (CI/CD, provisioning):

```bash
# List all available packages
./unattended_setup.sh ls

# Install specific packages
./unattended_setup.sh --packages <package-1>,<package-2>,<package-3>,...

# Examples:
./unattended_setup.sh --packages base-tools,git,zsh,docker,nodejs
./unattended_setup.sh --packages git,nvim,tmux --verbose
./unattended_setup.sh --packages docker,nodejs --dry-run
```

## 📦 Available Packages

The following packages can be installed individually or in groups:

### Core/Minimal Packages
- **base-tools** - Essential CLI utilities (fzf, ripgrep, bat, fd, eza, zoxide, etc.)
- **git** - Git configuration with custom aliases and settings
- **bash** - Bash shell configuration with Oh My Posh or Starship prompt
- **tmux** - Terminal multiplexer configuration
- **yazi** - Modern file manager

### Development Languages & Runtimes
- **nodejs** - Node.js runtime (v22/24, configurable)
- **python** - Python programming environment
- **golang** - Go programming language (v1.25.4)
- **dotnet** - .NET SDK (v10.0)
- **rustup** - Rust toolchain installer
- **powershell** - PowerShell cross-platform shell

### Cloud & DevOps Tools
- **docker** - Container platform
- **ansible** - Automation and configuration management
- **terraform** - Infrastructure as Code
- **aws-cli** - Amazon Web Services CLI
- **gcp-cli** - Google Cloud Platform CLI

### Editors & IDEs
- **nvim** - Neovim with custom configuration
- **zed** - Zed code editor
- **vscode** - Visual Studio Code
- **jetbrains-toolbox** - JetBrains development tools manager

### Terminal Emulators
- **kitty** - GPU-accelerated terminal emulator
- **tabby** - Modern terminal application

### System & Display Tools
- **fastfetch** - System information display
- **onefetch** - Git repository information display
- **glow** - Markdown renderer for the terminal

### Developer Tools
- **github-cli** - GitHub command-line interface
- **claude-code** - Claude AI coding assistant
- **opencode** - OpenCode configuration

### Desktop Environment
- **hypr** - Hyprland window manager configuration

### Advanced Shell
- **zsh** - Z shell with Oh My Zsh or standalone configuration

### Package Groups

Packages are organized into logical groups for easy installation:

- **Minimal**: `base-tools,bash,git,tmux,yazi`
- **Console**: Minimal + `nodejs,dotnet,golang,fastfetch,onefetch,glow,claude-code,opencode`
- **Desktop**: Console + `kitty,zed,hypr`
- **Console Extra**: `ansible,docker,powershell,python,rustup,github-cli,aws-cli,gcp-cli,terraform,nvim`
- **Desktop Extra**: Console Extra + `tabby,vscode,jetbrains-toolbox`

To see the complete, current list of available packages:
```bash
./unattended_setup.sh ls
```

## 📁 Project Structure

```
dotfiles/
├── setup.sh                    # Interactive setup script
├── unattended_setup.sh         # Automated setup script
├── update.sh                   # Update installed tools
├── _scripts/
│   └── core/                   # 50+ modular install scripts
│       ├── _helpers.sh         # Shared functions library
│       ├── _options.sh         # Package definitions
│       ├── *-install.sh        # Tool installation scripts
│       └── *-setup.sh          # Configuration setup scripts
├── bash/                       # Bash configuration
│   └── .config/bash/
│       └── config.bash
├── zsh/                        # ZSH configurations
│   ├── README.md               # Detailed ZSH documentation
│   └── .config/zsh/
│       ├── config.zsh          # Standard ZSH config
│       └── config-standalone.zsh  # Self-contained ZSH config
├── git/                        # Git configuration
├── nvim/                       # Neovim configuration
├── tmux/                       # Tmux configuration
├── kitty/                      # Kitty terminal config
├── tabby/                      # Tabby terminal config
├── zed/                        # Zed editor config
├── hypr/                       # Hyprland config
├── starship/                   # Starship prompt config
├── oh-my-posh/                 # Oh My Posh themes
├── yazi/                       # Yazi file manager config
├── fastfetch/                  # Fastfetch system info config
├── opencode/                   # OpenCode configuration
└── _extra/                     # Additional configs & templates
```

## 🔧 Configuration Management

This project uses **GNU Stow** for symlink-based configuration management:

- Configurations are organized in separate directories (bash/, git/, nvim/, etc.)
- Each directory can be "stowed" independently to `$HOME`
- Easy to enable/disable individual configs
- No file copying - uses symlinks for instant updates
- Simple backup and version control
- Existing configurations are automatically backed up with `.bak` extension

### How It Works

When you install a package like `git` or `bash`, the setup script:
1. Backs up any existing configuration files
2. Creates symlinks from `~/.dotfiles/<package>/` to `$HOME`
3. Preserves your ability to customize with local override files

Example: Installing bash configuration creates:
- `~/.bashrc` → symlink to `~/.dotfiles/bash/.bashrc`
- `~/.bashrc.local` → your local customizations (not tracked by git)

## 📋 Supported Distributions

| Distribution | Versions | Status |
|-------------|----------|--------|
| Arch Linux | Rolling | ✅ Fully Supported |
| Debian | 11+, 12, 13 | ✅ Fully Supported |
| Ubuntu | 22.04, 24.04, 25.04+ | ✅ Fully Supported |
| Pop!_OS | 22.04+ | ✅ Fully Supported |
| Fedora | 40+ | ✅ Fully Supported |
| RHEL | 9+ | ✅ Fully Supported |
| WSL2 | All supported distros | ✅ Special WSL2 support |

## 🎯 Update System and Installed Tools

```bash
./update.sh
```

This will:
- Update system packages (apt, dnf, pacman, etc.)
- Update Flatpak packages
- Update Homebrew packages
- Update npm global packages
- Update oh-my-posh

## 🛠️ Customization

### Local Overrides

Create local configuration files that won't be tracked by git:

- `~/.bashrc.local` - Local bash customizations
- `~/.zshrc.local` - Local zsh customizations
- `~/.config/git.user/config` - User-specific git config

### Default Versions

The following default versions are configured (see `_scripts/core/_options.sh`):

- Node.js: v22 (Fedora/RHEL) or v24 (Arch/Debian/Ubuntu)
- .NET SDK: v10.0
- Go: v1.25.4
- Nerd Fonts: v3.4.0 (CascadiaCode)
- Bash Prompt: Oh My Posh
- ZSH Prompt: Oh My Posh

### Modify Installation Options

Edit `_scripts/core/_options.sh` to change default versions, installation modes, or add new packages.

## 💡 Common Use Cases

### Developer Workstation Setup
```bash
# Full development environment with Docker, Node.js, and Python
./unattended_setup.sh --packages base-tools,git,bash,tmux,nvim,docker,nodejs,python,github-cli
```

### DevOps Engineer Setup
```bash
# Infrastructure and cloud tools
./unattended_setup.sh --packages base-tools,git,bash,docker,ansible,terraform,aws-cli,gcp-cli,kubectl
```

### Minimal Console Setup
```bash
# Lightweight setup for servers
./unattended_setup.sh --packages base-tools,git,bash,tmux
```

### Frontend Developer Setup
```bash
# Web development environment
./unattended_setup.sh --packages base-tools,git,bash,nodejs,vscode,github-cli
```

### .NET Developer Setup
```bash
# .NET development environment
./unattended_setup.sh --packages base-tools,git,bash,dotnet,vscode,github-cli
```

### Desktop Environment Setup
```bash
# Full desktop with Hyprland
./unattended_setup.sh --packages base-tools,git,bash,kitty,hypr,zed,vscode
```

## 🧪 Testing

### Dry Run Mode

Test what would be installed without making changes:

```bash
./unattended_setup.sh --packages git,nvim,tmux --dry-run
```

### Verbose Mode

Enable verbose output for debugging:

```bash
./unattended_setup.sh --packages docker,nodejs --verbose

# Combine flags
./unattended_setup.sh --packages python,golang --verbose --dry-run
```

## 🔍 Quick Reference

### Essential Commands

```bash
# List all available packages
./unattended_setup.sh ls

# Interactive installation with menu
./setup.sh

# Install specific packages
./unattended_setup.sh --packages git,bash,tmux,nvim

# Test installation (dry run)
./unattended_setup.sh --packages docker,nodejs --dry-run

# Verbose output for debugging
./unattended_setup.sh --packages python --verbose

# Update all installed tools
./update.sh
```

### Configuration Locations

- **Bash**: `~/.config/bash/config.bash` (sourced from `~/.bashrc`)
- **ZSH**: `~/.config/zsh/config.zsh` or `config-standalone.zsh`
- **Git**: `~/.config/git/config` (user settings in `~/.config/git.user/config`)
- **Neovim**: `~/.config/nvim/`
- **Tmux**: `~/.config/tmux/tmux.conf`
- **Kitty**: `~/.config/kitty/kitty.conf`
- **Yazi**: `~/.config/yazi/`
- **Oh My Posh**: `~/.config/oh-my-posh/themes/`

### Local Override Files

These files are ignored by git and allow personal customizations:

- `~/.bashrc.local` - Local bash configuration
- `~/.zshrc.local` - Local ZSH configuration  
- `~/.config/git.user/config` - User-specific git settings (name, email, etc.)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development

When adding new installation scripts:

1. Follow the existing script structure
2. Use the helper functions from `_scripts/core/_helpers.sh`
3. Support all major distributions (or clearly document limitations)
4. Add dry-run and verbose mode support
5. Test on multiple distributions
6. Add the package to `_options.sh` in the appropriate task arrays
7. Map the task type (install/setup) in the `TASK_TYPES` associative array

For detailed coding guidelines for AI agents and developers, see [AGENTS.md](AGENTS.md).

### Code Style

- Use shellcheck for linting
- Quote all variable expansions: `"$variable"`
- Use `[[ ]]` for conditionals, not `[ ]`
- Use 2 spaces for indentation (no tabs)
- Add comprehensive error handling
- Support `--verbose` and `--dry-run` flags
- Use helper functions: `cecho`, `decho`, `install_package`, `stow_package`

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🐛 Troubleshooting

### Common Issues

**Permission Denied**
```bash
# Make scripts executable
chmod +x setup.sh unattended_setup.sh update.sh
```

**Package Not Found**
```bash
# Verify package name
./unattended_setup.sh ls
```

**Stow Conflicts**
```bash
# Existing configs are automatically backed up with .bak extension
# To manually remove stowed configs:
cd ~/.dotfiles
stow -D bash  # Unstow bash config
```

**System Update Fails**
```bash
# Update manually first
sudo apt update && sudo apt upgrade  # Debian/Ubuntu
sudo dnf update  # Fedora/RHEL
sudo pacman -Syu  # Arch
```

### Getting Help

For detailed error information, use verbose mode:
```bash
./unattended_setup.sh --packages <package> --verbose
```

Check individual script logs in verbose mode for specific issues.

## 🙏 Acknowledgments

- Inspired by various dotfiles repositories across the GitHub community
- Built with insights from Oh-My-Zsh, Prezto, and other shell frameworks
- Special thanks to the creators of all the amazing tools included
- Icons and terminal themes from Nerd Fonts project

---

**Note**: These dotfiles are personalized for development workflows but designed to be easily customizable. Feel free to fork and adapt to your needs!
