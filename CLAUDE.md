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

### Claude Code Config (`claude-code/`)
Not stowed — deployed imperatively by `claude-code-setup.sh`. Files under `claude-code/user-config/` are copied/merged into `~/.claude/`:
- `statusline-command.sh` / `statusline-command.ps1` — ANSI status-line script that reads Claude Code's JSON payload via stdin and outputs two formatted lines (directory, git branch, model, context %, rate limits, cost). Copied to `~/.claude/statusline-command.sh` and registered via `settings.json` `statusLine.command`.
- `settings-part.json` — partial `~/.claude/settings.json` merged with `jq -s '.[0] * .[1]'`.
- `CLAUDE.md` — seeded as `~/.claude/CLAUDE.md` only if the file does not yet exist.

The setup script also installs plugins from two marketplaces (`claude-plugins-official`, `adeotek-plugins`) and LSP servers (gopls, csharp-ls, vtsls/typescript, pyright, lua-language-server).

### OpenCode Config (`opencode/`)
Not stowed — deployed imperatively by `opencode-setup.sh`. Samples are copied to `~/.config/opencode/` only if the target does not yet exist:
- `opencode.jsonc.sample` → `~/.config/opencode/opencode.jsonc` — global config with model, plugins, server, and multi-agent definitions (`build`, `plan`, `code-review`)
- `AGENTS.md.sample` → `~/.config/opencode/AGENTS.md` — system prompt for the primary agent
- `agents/`, `skills/`, `plugins/` — agent definitions, skill files, and JS plugins (e.g. `plugins/graphify.js`)

### Auxiliary Utility Scripts (`tools/`, `win-tools/`)
These directories contain standalone helper scripts not managed by the task/stow system:
- `tools/.tools/cc-sessions.sh` — CLI for browsing Claude Code session transcripts.
- `win-tools/.tools/` — PowerShell utilities for Windows/WSL environments (firewall rules, port tools, GitHub stats, etc.).

### ZSH Configurations
`zsh/` contains two configs managed via `zsh-setup.sh`:
- `config.zsh` — original config requiring external plugins (zsh-syntax-highlighting, zsh-autosuggestions)
- `config-standalone.zsh` — self-contained config with no plugin manager; recommended for new setups

Default prompt for ZSH is `starship` (`OPT_ZSH_DEFAULT_PROMPT`); bash defaults to `oh-my-posh`.

### Local Overrides (untracked)
- `~/.bashrc.local` / `~/.zshrc.local` — shell customizations
- `~/.config/git.user/config` — user git identity (template in `_extra/git.user.config`)

### Shell Code Conventions
- `[[ ]]` for all conditionals (never `[ ]` or `test`)
- Always quote variable expansions: `"$var"`, `"${ARGS[key]}"`
- 2-space indentation; no tabs; Unix LF line endings
- `set -e` is **not** used — scripts allow graceful failures; check return codes explicitly
- Exit codes: `exit 1` (error), `exit 10` (user cancelled)
- Output helpers (from `_helpers.sh`): `cecho "color" "msg"`, `decho "color" "msg"` (verbose-only), `aecho ARRAY "prefix" "color" "pfx_color"`
- Key helper functions: `install_package`, `stow_package`, `execute_command`, `rename_dir_if_exists`, `rename_file_if_exists`
- Argument parsing: `declare -A ARGS=(["flag"]="")` then `process_args "$@"` — populates `ARGS` and sets `VV`/`DRY_RUN`

### Commit Message Convention
Format: `[type:scope] description` (e.g., `[fix:config] ghostty config fixes`, `[feat:scripts] helm install script`)

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- Dirty graphify-out/ files are expected after hooks or incremental updates — not a reason to skip graphify. Only skip if the task is about stale graph output or the user says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
