# Agent Coding Guidelines for AdeoTEK Dotfiles

Modular Bash-based system for managing Linux dev environments (Arch, Debian/Ubuntu/Pop!OS, Fedora/RHEL) via GNU Stow. WSL2 supported.

## Commands

```bash
./unattended_setup.sh ls                                          # list packages
./unattended_setup.sh --packages git,nvim --dry-run --verbose    # safe test run
cd _scripts/core && source _helpers.sh && source git-install.sh --verbose --dry-run
shellcheck _scripts/core/*.sh setup.sh unattended_setup.sh update.sh
```

## Architecture

### Entry Points
- `setup.sh` — interactive menu-driven setup
- `unattended_setup.sh` — CLI flags, good for automation/testing
- `update.sh` — system + tool updates
- `_scripts/core/_options.sh` — defines all task arrays and `TASK_TYPES`/`TASK_ARGS` mappings

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

### GNU Stow Configuration Directories
Config directories (e.g., `bash/`, `git/`, `nvim/`) mirror `$HOME`. Editing here immediately affects the live symlinked system. `stow_package` helper wraps stow with backup logic.

### AI Tool Configs
Not stowed — deployed imperatively by their respective setup scripts. Files copied (not symlinked), only if target does not yet exist.

**`claude-code/`** — deployed by `claude-code-setup.sh` into `~/.claude/`:
- `settings-part.json` — partial settings merged with `jq -s '.[0] * .[1]'`
- `statusline-command.sh/.ps1` — ANSI status-line script
- `CLAUDE.md` — seeded only if not yet present
- Also installs plugins (`claude-plugins-official`, `adeotek-plugins`) and LSP servers

**`opencode/`** — deployed by `opencode-setup.sh` into `~/.config/opencode/`:
- `opencode.jsonc.sample` → global config with model, plugins, server, multi-agent defs (`build`, `plan`, `code-review`)
- `AGENTS.md.sample` → system prompt for the primary agent
- `agents/`, `skills/`, `plugins/` — agent definitions, skill files, JS plugins

### ZSH Configurations
`zsh/` contains two configs via `zsh-setup.sh`:
- `config.zsh` — requires external plugins (zsh-syntax-highlighting, zsh-autosuggestions)
- `config-standalone.zsh` — self-contained; recommended for new setups

Default ZSH prompt: `starship`; bash: `oh-my-posh`.

### Auxiliary Utility Scripts
- `tools/.tools/cc-sessions.sh` — CLI for browsing AI coding session transcripts
- `win-tools/.tools/` — PowerShell utilities for Windows/WSL (firewall rules, port tools, GitHub stats, etc.)

### Local Overrides (untracked)
- `~/.bashrc.local` / `~/.zshrc.local` — shell customizations
- `~/.config/git.user/config` — user git identity (template in `_extra/git.user.config`)

## Code Conventions

- `[[ ]]` for all conditionals (never `[ ]` or `test`); always quote variable expansions
- 2-space indentation; no tabs; Unix LF line endings
- `set -e` is **not** used — check return codes explicitly
- Exit codes: `exit 1` (error), `exit 10` (user cancelled)
- SCREAMING_SNAKE_CASE for globals/arrays; snake_case for functions; kebab-case for files
- Use `local` for function-scoped variables; validate params at the top of functions
- Output helpers: `cecho "color" "msg"`, `decho "color" "msg"` (verbose-only), `aecho ARRAY "prefix" "color" "pfx_color"`
- Key helpers: `install_package`, `stow_package`, `execute_command`, `rename_dir_if_exists`, `rename_file_if_exists`
- Argument parsing: `declare -A ARGS=(["flag"]="")` then `process_args "$@"` — sets `VV`/`DRY_RUN`
- Dry run: guard all side effects with `if [ "$DRY_RUN" -ne "1" ]; then … else cecho "yellow" "DRY-RUN: …"; fi`
- Multi-distro: every install script must handle `arch`, `debian|ubuntu|pop`, and `fedora|redhat` via a `case $CURRENT_OS_ID` block
- WSL2 special handling via `IF_WSL2` variable and `enable_wsl_systemd` function

## Script Initialization Pattern
Every `_scripts/core/` script begins with this guard (supports direct execution and sourcing):
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

## Adding a New Package
1. Create `_scripts/core/<name>-install.sh` and/or `<name>-setup.sh`
2. Add to the appropriate tier array(s) in `_options.sh` (see hierarchy above)
3. Add a `TASK_TYPES` entry mapping the name to `"install"` or `"setup"`
4. Optionally add a `TASK_ARGS` entry for default arguments
5. Add a config directory `<name>/` for stowed dotfiles (if applicable)
6. Test with `--dry-run` on all supported distributions

## Commit Message Convention
Format: `[type:scope] description` (e.g., `[fix:config] ghostty config fixes`, `[feat:scripts] helm install script`)

## graphify

This project has a knowledge graph at graphify-out/.

- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts.
- Dirty graphify-out/ files are expected after hooks or incremental updates — not a reason to skip graphify. Only skip if the task is about stale graph output or the user says not to use it.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).

## Agent Operational Rules

### 1. Verification Before Done
Before declaring any task complete: run `shellcheck`, fix all violations; test with `--dry-run --verbose` before destructive changes.

### 2. Analysis/Plan Phase
For non-trivial changes (cross-file, >10 lines, refactoring, new feature): research → present a plan → wait for approval before writing code. Simple changes (typo, one-liner, docs) may skip.

### 3. General Conduct
- Be concise and direct; use bullet points for plans.
- For errors: include the command, full error output, and proposed fix.
- When uncertain about intent, ask rather than assume.

### 4. Browser Automation
Use `playwright-cli` for browser automation. Prefer headless mode (default) unless a visible browser is explicitly needed.
