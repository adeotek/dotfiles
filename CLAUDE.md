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
- `_scripts/core/_options.sh` — defines all task arrays and `TASK_TYPES`/`TASK_ARGS` mappings

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

### Task Array Hierarchy
`_options.sh` composes arrays from smaller groups — understand the hierarchy before adding a package:

```
MINIMAL_TASKS          → base essentials (base-tools, bash, git, tmux, yazi)
CONSOLE_ONLY_TASKS     → dev tools added at Console tier (nodejs, golang, claude-code, glow, …)
CONSOLE_TASKS          → MINIMAL + CONSOLE_ONLY
CONSOLE_EXTRA_TASKS    → opt-in extras (docker, nvim, kubectl, dotnet, opencode, …)
DESKTOP_ONLY_TASKS     → GUI-only apps (ghostty, zed)
DESKTOP_TASKS          → CONSOLE + DESKTOP_ONLY
ALL_CONSOLE_TASKS      → CONSOLE + CONSOLE_EXTRA
DESKTOP_EXTRA_TASKS    → CONSOLE_EXTRA + GUI extras (kitty, tabby, vscode, jetbrains-toolbox)
ALL_DESKTOP_TASKS      → DESKTOP + DESKTOP_EXTRA
ALL_TASKS              → deduplicated union of everything (sorted)
```

### Adding a New Package
1. Create `_scripts/core/<name>-install.sh` and/or `<name>-setup.sh`
2. Add to the appropriate tier array(s) in `_options.sh` (see hierarchy above)
3. Add a `TASK_TYPES` entry mapping the name to `"install"` or `"setup"`
4. Optionally add a `TASK_ARGS` entry for default arguments (e.g. `--prompt starship`)
5. Add a config directory `<name>/` for stowed dotfiles (if applicable)

### GNU Stow Configuration Directories
Config directories (e.g., `bash/`, `git/`, `nvim/`) mirror the `$HOME` directory structure. Editing files here immediately affects the live symlinked system. `stow_package` helper wraps the stow call with backup logic.

### ZSH Configurations
`zsh/` contains two configs managed via `zsh-setup.sh`:
- `config.zsh` — original config requiring external plugins (zsh-syntax-highlighting, zsh-autosuggestions)
- `config-standalone.zsh` — self-contained config with no plugin manager; recommended for new setups

Default prompt for ZSH is `starship` (`OPT_ZSH_DEFAULT_PROMPT`); bash defaults to `oh-my-posh`.

### Local Overrides (untracked)
- `~/.bashrc.local` / `~/.zshrc.local` — shell customizations
- `~/.config/git.user/config` — user git identity (template in `_extra/git.user.config`)

### Commit Message Convention
Format: `[type:scope] description` (e.g., `[fix:config] ghostty config fixes`, `[feat:scripts] helm install script`)

### Code Intelligence
Prefer LSP over Grep/Glob/Read for code navigation:
- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find all call sites first.
Use Grep/Glob only for text/pattern searches (comments, strings, config values) where LSP doesn't help.
After writing or editing code, check LSP diagnostics before moving on.
