# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AdeoTEK Dotfiles — a modular Bash-based system for managing Linux development environments across Arch, Debian/Ubuntu/Pop!OS, and Fedora/RHEL. Uses GNU Stow for symlinking configurations to `$HOME`.

**Full coding guidelines are in [AGENTS.md](./AGENTS.md)** — read it before writing or modifying scripts.

## Commands

```bash
# List all available packages
./unattended_setup.sh ls

# Dry-run a package install (safe for testing)
./unattended_setup.sh --packages git,nvim --dry-run --verbose

# Run a single script directly (must source helpers first)
cd _scripts/core && source _helpers.sh && source git-install.sh --verbose --dry-run

# Lint all shell scripts
shellcheck _scripts/core/*.sh
shellcheck setup.sh unattended_setup.sh update.sh
```

## Architecture

### Entry Points
- `setup.sh` — interactive menu-driven setup
- `unattended_setup.sh` — CLI flags, good for automation/testing
- `update.sh` — system + tool updates
- `_scripts/core/_options.sh` — defines all task arrays (`MINIMAL_TASKS`, `CONSOLE_TASKS`, etc.) and `TASK_TYPES` mappings

### Script Initialization Pattern
Every script in `_scripts/core/` begins with this guard to support both direct execution and sourcing:

```bash
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

### Shared State (set by `_helpers.sh`)
| Variable | Purpose |
|----------|---------|
| `RDIR` | Repo root directory |
| `CDIR` | `_scripts/core/` path |
| `CURRENT_OS_ID` | Detected OS (`arch`, `debian`, `ubuntu`, `pop`, `fedora`, `redhat`) |
| `DRY_RUN` | 1 when `--dry-run` passed |
| `VV` | 1 when `--verbose` passed |
| `IF_WSL2` | 1 when running in WSL2 |

### Adding a New Package
1. Create `_scripts/core/<name>-install.sh` and/or `<name>-setup.sh`
2. Add to the appropriate task array(s) in `_options.sh` (`MINIMAL_TASKS`, `CONSOLE_TASKS`, `DESKTOP_TASKS`, `CONSOLE_EXTRA_TASKS`, `ALL_TASKS`)
3. Add a `TASK_TYPES` entry mapping the name to `"install"`, `"setup"`, or `"both"`
4. Add a config directory `<name>/` for stowed dotfiles (if applicable)

### GNU Stow Configuration Directories
Config directories (e.g., `bash/`, `git/`, `nvim/`) mirror the `$HOME` directory structure. Editing files here immediately affects the live symlinked system. `stow_package` helper wraps the stow call with backup logic.

### Commit Message Convention
Format: `[type:scope] description` (e.g., `[fix:config] ghostty config fixes`, `[feat:scripts] helm install script`)
