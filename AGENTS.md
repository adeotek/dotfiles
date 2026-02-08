# Agent Coding Guidelines for AdeoTEK Dotfiles

This document provides essential information for AI coding agents working in this repository. The project is a modular collection of shell scripts for managing Linux dotfiles and development environment setup across multiple distributions.

## Project Overview

- **Type**: Shell script-based dotfiles management system
- **Language**: Bash
- **Structure**: Modular install/setup scripts with GNU Stow for symlink management
- **Supported Distributions**: Arch, Debian, Ubuntu, Pop!OS, Fedora, RHEL
- **Special Support**: WSL2 compatibility included

## Testing & Execution Commands

### Run Interactive Setup
```bash
./setup.sh
```

### Run Unattended Setup (for testing specific packages)
```bash
# List all available packages
./unattended_setup.sh ls

# Install specific packages
./unattended_setup.sh --packages base-tools,git,tmux

# Dry run (test without making changes)
./unattended_setup.sh --packages git,nvim --dry-run

# Verbose mode for debugging
./unattended_setup.sh --packages docker --verbose

# Combined flags
./unattended_setup.sh --packages nodejs,python --verbose --dry-run
```

### Test Individual Scripts
```bash
# Test a single install script
cd _scripts/core
source _helpers.sh
source git-install.sh --verbose --dry-run

# Test a setup script with arguments
source bash-setup.sh --prompt oh-my-posh --verbose
```

### Update System & Tools
```bash
./update.sh
```

### Validate Shell Scripts
```bash
# Use shellcheck for linting (recommended)
shellcheck _scripts/core/*.sh
shellcheck setup.sh unattended_setup.sh update.sh
```

## Code Style Guidelines

### Shell Script Conventions

#### File Structure
- All scripts must start with shebang: `#!/bin/bash`
- Include descriptive header comments explaining the script's purpose
- Scripts are either `*-install.sh` (installation) or `*-setup.sh` (configuration)
- Source helper files: `source "$CDIR/_helpers.sh"`

#### Naming Conventions
- **Files**: Use kebab-case with type suffix (e.g., `git-install.sh`, `bash-setup.sh`)
- **Variables**: Use SCREAMING_SNAKE_CASE for globals (e.g., `CURRENT_OS_ID`, `DRY_RUN`)
- **Functions**: Use snake_case (e.g., `install_package`, `stow_package`)
- **Arrays**: Use SCREAMING_SNAKE_CASE (e.g., `MINIMAL_TASKS`, `ALL_TASKS`)

#### Variable Usage
- **Always quote variable expansions**: `"$variable"` not `$variable`
- Use curly braces for clarity: `"${ARGS[packages]}"`
- Declare arrays explicitly: `declare MINIMAL_TASKS=(...)` or `declare -A TASK_TYPES=(...)`
- Use associative arrays for key-value pairs: `declare -A MENU_OPTIONS=(...)`

#### Conditionals
- **Use `[[ ]]` for conditionals**, not `[ ]` or `test`
- Quote strings in conditionals: `[[ "$var" == "value" ]]`
- Use `-z` for empty checks: `[[ -z "$variable" ]]`
- Use `-n` for non-empty checks: `[[ -n "$variable" ]]`
- File checks: `[[ -f "$file" ]]`, `[[ -d "$dir" ]]`

#### Functions
- Start with parameter validation
- Use `local` for function-scoped variables
- Return early on errors
- Use helper functions from `_helpers.sh` when available

```bash
function install_package() {
  local package="$1"
  local check_command="$2"
  
  if [[ -z "$package" ]]; then
    cecho "red" "ERROR: Package name required!"
    return 1
  fi
  
  # Implementation...
}
```

#### Error Handling
- Check command results: `if command >/dev/null 2>&1; then`
- Use `set -e` sparingly (not used in this project to allow graceful failures)
- Provide clear error messages with `cecho "red" "ERROR: message"`
- Exit with meaningful codes: `exit 1` (general error), `exit 10` (user cancelled)

#### Output & Logging
- Use helper functions for colored output:
  - `cecho "color" "message"` - Colored echo
  - `decho "color" "message"` - Debug echo (only in verbose mode)
  - `aecho ARRAY_NAME "prefix" "color" "prefix_color"` - Array echo
- Available colors: black, red, green, yellow, blue, magenta, cyan, white
- Use `-n` flag for no newline: `cecho "yellow" -n "Prompt: "`

#### Indentation & Formatting
- **Use 2 spaces** for indentation (as per `.editorconfig`)
- No tabs - convert to spaces
- End files with newline (insert_final_newline = true)
- Use Unix line endings (LF, not CRLF)

#### Case Statements
```bash
case $CURRENT_OS_ID in
  arch)
    # Arch-specific code
    ;;
  debian|ubuntu|pop)
    # Debian-based code
    ;;
  fedora|redhat)
    # RPM-based code
    ;;
  *)
    cecho "red" "Unsupported OS: $CURRENT_OS_ID"
    exit 1
    ;;
esac
```

### Package Management Patterns

#### Multi-Distribution Support
Every install script must support all distributions:
- Arch: `pacman`, `yay` (AUR)
- Debian/Ubuntu/Pop!OS: `apt-get`, `dpkg`
- Fedora/RHEL: `dnf`, `rpm`

#### Using Helper Functions
- `install_package "$pkg" "$check_cmd" "$install_cmd" "$additional_pkgs"`
- `stow_package "$pkg" "$action" "$dir_to_rename" "$file_to_rename"`
- `execute_command "$cmd" "$success_message"`
- `rename_dir_if_exists "$path"` and `rename_file_if_exists "$path"`

#### Dry Run Support
All scripts must respect `$DRY_RUN` flag:
```bash
if [ "$DRY_RUN" -ne "1" ]; then
  # Actual execution
else
  cecho "yellow" "DRY-RUN: would execute command"
fi
```

### Configuration Management

#### GNU Stow Usage
- Configurations organized in separate directories (e.g., `bash/`, `git/`, `nvim/`)
- Each directory stowed to `$HOME`: `stow --dir="$RDIR" --target="$HOME" --stow bash`
- Backup existing configs before stowing: use `rename_dir_if_exists` and `rename_file_if_exists`

#### Local Overrides
Support user customizations that won't be tracked:
- `~/.bashrc.local` - Local bash customizations
- `~/.zshrc.local` - Local zsh customizations  
- `~/.config/git.user/config` - User git config

## Common Patterns & Best Practices

### Script Initialization
```bash
#!/bin/bash

# Init
if [[ -z "$RDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "$(cd "${0%/*}" && pwd)")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core"
  source "$CDIR/_helpers.sh"
fi
```

### Argument Processing
Scripts accept global flags: `--verbose`, `--dry-run`, and custom flags
```bash
declare -A ARGS=(["custom-arg"]="")
process_args "$@"  # Populates ARGS array and sets VV, DRY_RUN
```

### Adding New Packages
1. Create `<package>-install.sh` or `<package>-setup.sh` in `_scripts/core/`
2. Add package to appropriate task arrays in `_options.sh`
3. Add task type mapping to `TASK_TYPES` in `_options.sh`
4. Test with `--dry-run` on all supported distributions
5. Support all major distributions or clearly document limitations

## File Locations

- **Core scripts**: `_scripts/core/`
- **Helper functions**: `_scripts/core/_helpers.sh`
- **Package definitions**: `_scripts/core/_options.sh`
- **Config directories**: `bash/`, `git/`, `nvim/`, `tmux/`, `zsh/`, etc.
- **Main entry points**: `setup.sh`, `unattended_setup.sh`, `update.sh`

## Important Notes

- Never modify system git config directly - scripts respect user settings
- WSL2 has special handling via `IF_WSL2` variable and `enable_wsl_systemd` function
- Some tools install from source, others use package managers - check existing patterns
- Verbose output controlled by `VV` variable (set via `--verbose`)
- All user prompts should have clear defaults and allow cancellation
