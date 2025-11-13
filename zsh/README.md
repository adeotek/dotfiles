# ZSH Configuration

This directory contains ZSH configurations for your shell environment.

## Available Configurations

### 1. `config.zsh` - Original Configuration
The existing configuration that integrates with the dotfiles setup using GNU Stow.

**Features:**
- Integration with oh-my-posh/starship
- Tool integrations (zoxide, fzf, yazi, hstr)
- Requires external plugins (zsh-syntax-highlighting, zsh-autosuggestions)

**Usage:**
```bash
# This is automatically sourced if you run the zsh-setup.sh script
source ~/.config/zsh/config.zsh
```

### 2. `config-standalone.zsh` - New Standalone Configuration (Recommended)
A comprehensive, self-contained ZSH configuration without any plugin manager requirements.

**Features:**
- ✨ **Git Integration** - Full git prompt with branch/status, extensive aliases
- 🐳 **Docker Integration** - Complete docker and docker-compose aliases
- 📁 **Smart Autocomplete** - Advanced completion with fuzzy matching
- 📚 **History Management** - 50k history with deduplication and search
- 🎨 **Syntax Highlighting** - Uses system packages if available
- 💡 **Auto-suggestions** - Command suggestions from history
- 🔍 **FZF Integration** - Fuzzy finding for files, directories, processes
- 🧭 **Smart Navigation** - Zoxide integration for quick directory jumping
- ⚡ **Performance** - Optimized for fast startup
- 🎯 **Modern Prompt** - Two-line prompt with git status and colors
- 🛠️ **Utility Functions** - extract, mkcd, weather, cheat sheets, and more
- ⌨️ **Key Bindings** - Emacs-style with modern enhancements

**No plugin manager required!** Everything is self-contained and portable.

## Installation

### Option 1: Use Standalone Configuration (Recommended)

1. **Add to your `~/.zshrc`:**
   ```bash
   source ~/.config/zsh/config-standalone.zsh
   ```

2. **Optional: Install recommended packages for enhanced features**
   ```bash
   # Ubuntu/Debian
   sudo apt install zsh-syntax-highlighting zsh-autosuggestions fzf bat fd-find ripgrep eza

   # Fedora
   sudo dnf install zsh-syntax-highlighting zsh-autosuggestions fzf bat fd-find ripgrep eza

   # Arch
   sudo pacman -S zsh-syntax-highlighting zsh-autosuggestions fzf bat fd ripgrep eza
   ```

   The configuration works without these packages but they enhance the experience!

3. **Reload your shell:**
   ```bash
   exec zsh
   ```

### Option 2: Use Original Configuration

Run the setup script from the dotfiles root:
```bash
./setup.sh
# Select: zsh
```

## Key Features & Usage

### Git Aliases
- `g` - git
- `gst` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gco` - git checkout
- `glog` - pretty git log
- And many more! (see config file)

### Docker Aliases
- `d` - docker
- `dc` - docker compose
- `dps` - docker ps
- `dex` - docker exec -it
- `dcup` - docker compose up
- `dcdown` - docker compose down
- And more!

### Useful Functions

#### `mkcd <directory>`
Create a directory and cd into it:
```bash
mkcd ~/projects/new-project
```

#### `extract <archive>`
Extract any archive format:
```bash
extract file.tar.gz
extract file.zip
```

#### `fe` (with fzf)
Fuzzy find and edit a file:
```bash
fe
```

#### `fcd` (with fzf)
Fuzzy find and change directory:
```bash
fcd
```

#### `fkill` (with fzf)
Fuzzy find and kill a process:
```bash
fkill
```

#### `weather [city]`
Check the weather:
```bash
weather London
weather  # Uses your location
```

#### `cheat <command>`
Get a cheat sheet for a command:
```bash
cheat tar
cheat git
```

### Key Bindings

- `Ctrl+R` - Fuzzy history search (if fzf installed)
- `Ctrl+T` - Fuzzy file search (if fzf installed)
- `Alt+C` - Fuzzy directory search (if fzf installed)
- `Up/Down` - Search history based on what you've typed
- `Ctrl+Left/Right` - Move by word
- `Home/End` - Move to beginning/end of line
- `Ctrl+X Ctrl+E` - Edit command in $EDITOR
- `Ctrl+Space` - Accept autosuggestion

### History

- 50,000 commands saved
- Shared across all terminals
- Duplicates removed
- Timestamped entries
- Search with Up/Down arrows

## Customization

### Local Overrides
Create `~/.zshrc.local` to add your own customizations without modifying the main config:

```bash
# ~/.zshrc.local
export MY_VAR="value"
alias myalias='command'
```

### Change Prompt
The prompt is defined near the end of the config file. Customize the `PROMPT` variable:

```bash
PROMPT='%F{blue}%~%f ${vcs_info_msg_0_} %# '
```

### Disable Welcome Message
Comment out the fastfetch/neofetch section at the end of the file.

## Troubleshooting

### Slow Startup
1. Remove the welcome message (fastfetch/neofetch)
2. Check which tools are being initialized (zoxide, fzf, etc.)
3. Use `zprof` to profile startup time

### Syntax Highlighting Not Working
Install the package for your distribution:
```bash
# Ubuntu/Debian
sudo apt install zsh-syntax-highlighting

# Fedora
sudo dnf install zsh-syntax-highlighting

# Arch
sudo pacman -S zsh-syntax-highlighting
```

### Completions Not Working
Run:
```bash
rm ~/.zcompdump*
exec zsh
```

## Migration from Oh-My-Zsh or Other Frameworks

The standalone configuration includes most features you'd get from Oh-My-Zsh without the overhead:

1. Backup your current `.zshrc`
2. Source the standalone config
3. Add any custom aliases to `~/.zshrc.local`
4. Enjoy faster startup times!

## Performance

The standalone configuration is optimized for performance:
- Lazy loading where possible
- Cached completions
- Minimal external dependencies
- Fast startup (~100-200ms vs 1-2s for Oh-My-Zsh)

## Credits

This configuration incorporates best practices from:
- ZSH documentation
- Oh-My-Zsh
- Prezto
- Various community contributions
