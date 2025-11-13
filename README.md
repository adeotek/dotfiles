# AdeoTEK Dotfiles

A comprehensive, modular collection of Linux dotfiles and automated installation scripts for setting up development environments across multiple distributions.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Distributions](https://img.shields.io/badge/distros-Arch%20%7C%20Debian%20%7C%20Ubuntu%20%7C%20Fedora%20%7C%20RHEL-green.svg)](#supported-distributions)

## ✨ Features

- 🎯 **Modular Architecture** - 48+ individual installation scripts for granular control
- 🐧 **Multi-Distribution** - Supports ArchLinux, Debian, Ubuntu, Pop!OS, Fedora and RedHat (RHEL)
- 🔧 **GNU Stow** - Symlink-based configuration management
- ⚡ **Interactive & Unattended** - Both modes supported for flexibility
- 🚀 **Comprehensive Tools** - Development tools, CLI utilities, desktop applications
- 🎨 **Shell Configurations** - Bash and advanced ZSH configurations
- 🔒 **WSL2 Support** - Special handling for Windows Subsystem for Linux

## 📦 What's Included

### Development Tools
- **Languages**: Node.js, Python, Go, Rust, .NET SDK, PHP
- **Cloud/DevOps**: Docker, AWS CLI, GCP CLI, Terraform, Ansible
- **Editors**: Neovim (with custom config), Zed, VS Code, JetBrains Toolbox

### CLI Utilities
- **Core**: git, tmux, fzf, ripgrep, bat, fd, eza, zoxide, yazi
- **System**: htop, btop, fastfetch, hstr, tldr
- **Package Managers**: Homebrew (Linux)

### Shell Environments
- **Bash**: Comprehensive configuration with tool integrations
- **ZSH**: Two configurations available:
  - Standard config with plugin support
  - Standalone config with all features built-in (no plugin manager needed)

### Desktop Applications
- **Terminals**: Kitty, Tabby, Alacritty, WezTerm
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

3. **Select packages to install from the menu**

### Unattended Installation

For automated setups (CI/CD, provisioning):

```bash
# use `./unattended_setup.sh ls` to see all available packages
./unattended_setup.sh --packages base-tools,git,zsh,docker,nodejs
```

Available options:
```
--base-tools      Base CLI tools (git, tmux, fzf, etc.)
--git             Git configuration
--bash            Bash configuration
--zsh             ZSH configuration
--prompt=<name>   oh-my-posh or starship
--docker          Docker and Docker Compose
--nodejs          Node.js
--golang          Go language
--rust            Rust language
--python          Python and pipx
--dotnet          .NET SDK
--nvim            Neovim with custom config
--tmux            Tmux with custom config
--mise            mise version manager
--asdf            asdf version manager
--homebrew        Homebrew package manager
--all             Install everything
```

## 📁 Project Structure

```
dotfiles/
├── setup.sh                    # Interactive setup script
├── unattended_setup.sh         # Automated setup script
├── update.sh                   # Update installed tools
├── _scripts/
│   └── core/                   # 48 modular install scripts
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
│       └── config-standalone.zsh  # Self-contained ZSH config (NEW!)
├── git/                        # Git configuration
├── nvim/                       # Neovim configuration
├── tmux/                       # Tmux configuration
├── kitty/                      # Kitty terminal config
├── hypr/                       # Hyprland config
├── starship/                   # Starship prompt config
├── oh-my-posh/                 # Oh My Posh themes
├── yazi/                       # Yazi file manager config
└── _extra/                     # Additional configs & templates
```

## 🔧 Configuration Management

This project uses **GNU Stow** for symlink-based configuration management:

- Configurations are organized in separate directories
- Each directory can be "stowed" independently
- Easy to enable/disable individual configs
- No file copying - uses symlinks
- Simple backup and version control

## 📋 Supported Distributions

| Distribution | Versions | Status |
|-------------|----------|--------|
| Arch Linux | Rolling | ✅ Fully Supported |
| Debian | 11, 12, 13 | ✅ Fully Supported |
| Ubuntu | 24.04, 25.04, 25.10 | ✅ Fully Supported |
| Pop!_OS | 22.04, 24.04 | ✅ Fully Supported |
| Fedora | 42, 43 | ✅ Fully Supported |
| RHEL | 9 | ✅ Fully Supported |

## 🎯 Update System and Installed Tools

```bash
./update.sh
```

This will:
- Update system packages
- Update Homebrew packages
- Update npm global packages
- Update cargo packages
- Update Go tools
- Update oh-my-posh/starship

## 🛠️ Customization

### Local Overrides

Create local configuration files that won't be tracked by git:

- `~/.bashrc.local` - Local bash customizations
- `~/.zshrc.local` - Local zsh customizations
- `~/.config/git.user/config` - User-specific git config

### Modify Installation Options

Edit `_scripts/core/_options.sh` to change default versions or add new packages.

## 🧪 Testing

### Dry Run Mode

Most scripts support dry-run mode:

```bash
# See what would be installed without actually installing
./unattended_setup.sh --base-tools --dry-run
```

### Verbose Mode

Enable verbose output for debugging:

```bash
./unattended_setup.sh --base-tools --verbose
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

### Development

When adding new installation scripts:

1. Follow the existing script structure
2. Use the helper functions from `_scripts/core/_helpers.sh`
3. Support all major distributions (or clearly document limitations)
4. Add dry-run mode support
5. Test on multiple distributions

### Code Style

- Use shellcheck for linting
- Quote all variable expansions
- Use `[[ ]]` for conditionals
- Add error handling

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Inspired by various dotfiles repositories across GitHub
- Built with insights from Oh-My-Zsh, Prezto, and other shell frameworks
- Thanks to the open source community for the amazing tools

---

**Note**: These dotfiles are personalized for my workflow but designed to be easily customizable. Feel free to fork and adapt to your needs!
