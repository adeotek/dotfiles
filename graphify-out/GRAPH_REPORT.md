# Graph Report - .dotfiles  (2026-08-30)

## Corpus Check
- 169 files · ~46,950 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 484 nodes · 641 edges · 115 communities (84 shown, 31 thin omitted)
- Extraction: 74% EXTRACTED · 26% INFERRED · 0% AMBIGUOUS · INFERRED: 169 edges (avg confidence: 0.6)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `9d15b11b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- adeotek_v2/keymaps.lua (Centralized Keymaps)
- config.bash
- Hermes Agent
- _options.sh (Task Arrays & Tiers)
- Headroom
- AdeoTEK Scripting Best Practices (Strictly Enforced)
- homebrew-install.sh
- AGENTS.md — Operational Rules for AI Agents
- yazi-install.sh
- wsl-setup-fedora-dev.sh
- microsoft-repo-install.sh
- claude-code-install.sh
- headroom-uninstall.sh
- Get-GitHubStats.ps1
- Run-LocalWinEnvSetup.ps1
- tutor.md
- Windows Network/Firewall Diagnostic Tools
- ghostty-install.sh
- AGENTS.md (Coding Guidelines)
- statusline-command.sh (Linux/WSL)
- k8s-repo-install.sh
- Neovim README.md
- oh-my-posh gbs.omp.yaml (Powerline Theme)
- cecho
- hermes-install.sh
- Dry-Run Safety Pattern
- opencode: .NET Unit Test Expert Agent
- adeotek_v1/plugins/lualine.lua (Statusline)
- start-opencode-server.sh
- cc-sessions.sh (Claude Code Session Browser)
- ZSH README.md (Config Guide)
- tui.json
- unattended_setup.sh
- fastfetch-install.sh
- opencode.json
- _helpers.sh
- tmux-install.sh
- rules/graphify.md
- workflows/graphify.md
- ai-config.bash
- devops.md
- expert.md
- setup.sh
- update.sh
- adeotek_v1/plugins/toggleterm.lua (Terminal)
- jetbrains-toolbox-install.sh
- graphify.js
- github-cli-install.sh
- uv-install.sh (Python Package Manager)
- docker-install.sh script
- golang-install.sh
- system-update.sh
- Homebrew Fallback Package Manager
- CLAUDE.md (User Claude Instructions)
- adeotek_v1/plugins/visual_multi.lua (Multi-cursor)
- adeotek_v2/plugins/copilot.lua (GitHub Copilot)
- adeotek_v2/plugins/git.lua (Gitsigns)
- adeotek_v2/plugins/lualine.lua (Statusline)
- adeotek_v2/plugins/which-key.lua (Keymap Discovery)
- jakoolit/plugins/alpha.lua (Dashboard)
- jakoolit/plugins/neo-tree.lua (File Explorer)

## God Nodes (most connected - your core abstractions)
1. `cecho()` - 59 edges
2. `decho()` - 28 edges
3. `install_package()` - 28 edges
4. `stow_package()` - 21 edges
5. `Headroom` - 10 edges
6. `Hermes Agent` - 9 edges
7. `execute_command()` - 8 edges
8. `AGENTS.md — Operational Rules for AI Agents` - 8 edges
9. `tools-setup.sh script` - 7 edges
10. `statusline-command-win.sh script` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Rename-Files.ps1 (Bulk Rename with Dry-Run)` --semantically_similar_to--> `Dry-Run Safety Pattern`  [INFERRED] [semantically similar]
  win-tools/.tools/Rename-Files.ps1 → _scripts/core/_helpers.sh
- `setup.sh (Interactive Setup)` --semantically_similar_to--> `unattended_setup.sh (Unattended Setup)`  [INFERRED] [semantically similar]
  setup.sh → unattended_setup.sh
- `adeotek_v2/plugins/telescope.lua (Fuzzy Finder)` --semantically_similar_to--> `jakoolit/plugins/telescope.lua (Fuzzy Finder)`  [INFERRED] [semantically similar]
  nvim/.config/nvim/lua/configs/adeotek_v2/plugins/telescope.lua → nvim/.config/nvim/lua/configs/jakoolit/plugins/telescope.lua
- `adeotek_v1/plugins/telescope.lua (Fuzzy Finder)` --semantically_similar_to--> `adeotek_v2/plugins/telescope.lua (Fuzzy Finder)`  [INFERRED] [semantically similar]
  nvim/.config/nvim/lua/configs/adeotek_v1/plugins/telescope.lua → nvim/.config/nvim/lua/configs/adeotek_v2/plugins/telescope.lua
- `ansible-install.sh script` --calls--> `cecho()`  [EXTRACTED]
  _scripts/core/ansible-install.sh → _scripts/core/_helpers.sh

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **LSP Ecosystem (v2)** — nvim_config_nvim_lua_configs_adeotek_v2_plugins_lsp_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_bufferline_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_theme_v2, concept_lsp_ecosystem [EXTRACTED 1.00]
- **adeotek_v1 Initialization Chain** — nvim_config_nvim_init, nvim_config_nvim_lua_config, nvim_config_nvim_lua_configs_adeotek_v1_init, nvim_config_nvim_lua_configs_adeotek_v1_config, nvim_config_nvim_lua_configs_adeotek_v1_lazy_init, nvim_config_nvim_lua_configs_adeotek_v1_keymaps [EXTRACTED 1.00]
- **ZSH Plugin Suite** — zsh_config_zsh_zsh_plugins_txt, zsh_readme, concept_zsh_standalone_config [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
- **AI Coding Tools** — scripts_core_claude_code_install, scripts_core_claude_code_setup, scripts_core_opencode_install, scripts_core_opencode_setup [INFERRED 0.85]
- **dotnet Testing Expertise (agent + skill)** — opencode_agent_dotnet_backend, opencode_agent_dotnet_tests, opencode_skill_dotnet_testing [INFERRED 0.85]
- **File Navigation & Fuzzy Find Cluster** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_telescope_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, nvim_config_nvim_lua_configs_adeotek_v1_plugins_neo_tree_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_nvim_tree_v2 [INFERRED 0.85]
- **adeotek_v1 UI Plugin Suite** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_catppuccin_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_lualine_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_bufferline_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_alpha_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_nvim_scrollbar_v1 [INFERRED 0.85]
- **Setup-Wraps-Install Pattern** — scripts_core_fastfetch_setup, scripts_core_fastfetch_install, scripts_core_git_setup, scripts_core_git_install, scripts_core_jetbrains_toolbox_setup, scripts_core_jetbrains_toolbox_install [INFERRED 0.85]
- **Shell Prompt Tools with Nerd Fonts** — scripts_core_starship_install, scripts_core_oh_my_posh_install, scripts_core_nerd_fonts_install [INFERRED 0.85]
- **Theme Integration Cluster (catppuccin + dependents)** — nvim_config_nvim_lua_configs_adeotek_v2_plugins_theme_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_nvim_tree_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_lsp_v2, nvim_config_nvim_lua_configs_adeotek_v1_plugins_catppuccin_v1 [INFERRED 0.85]
- **Cross-Platform Claude Code Session Browsers** — tools_tools_cc_sessions, win_tools_get_cc_sessions [INFERRED 0.95]
- **Kubernetes Toolchain** — scripts_core_k8s_repo_install, scripts_core_kubectl_install, scripts_core_helm_install [INFERRED 0.95]
- **Claude Code Statusline Variants** — claude_code_user_config_statusline_command, claude_code_user_config_statusline_command_win, claude_code_user_config_statusline_slim [INFERRED 0.95]
- **Telescope Fuzzy Finder Across All Configs** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_telescope_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, jakoolit_telescope [INFERRED 0.95]
- **Treesitter Across All Neovim Configs** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_treesitter_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_treesitter_v2, jakoolit_treesitter [INFERRED 0.95]
- **Windows Network & Firewall Tools** — win_tools_tools_add_winfirewallrule, win_tools_tools_get_winfirewallrulebyport, win_tools_run_port_listen, win_tools_run_port_probe [INFERRED 0.95]

## Communities (115 total, 31 thin omitted)

### Community 0 - "adeotek_v2/keymaps.lua (Centralized Keymaps)"
Cohesion: 0.06
Nodes (21): Centralized Keymap Architecture (v2 pattern), lazy.nvim Plugin Manager, LSP Ecosystem (lspconfig + mason + cmp + LuaSnip), NVIM_CONFIG Env Var Config Router, Theme Integration Pattern (catppuccin integrations), jakoolit/plugins/catppuccin.lua (Theme), jakoolit/plugins/lsp-config.lua (LSP), jakoolit/plugins/telescope.lua (Fuzzy Finder) (+13 more)

### Community 1 - "config.bash"
Cohesion: 0.08
Nodes (20): config.bash script, COLORTERM, EDITOR, LC_ALL, PATH, Shell PATH Setup (Homebrew/Rust/Go/dotnet), Install-Then-Setup Pattern, Shell Prompt Customization Tool (+12 more)

### Community 2 - "Hermes Agent"
Cohesion: 0.10
Nodes (19): API Server (port 8642), Architecture, config.yaml, Configuration, Connecting the Desktop GUI, Dashboard (port 9119), Documentation, .env (credentials) (+11 more)

### Community 3 - "_options.sh (Task Arrays & Tiers)"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 4 - "Headroom"
Cohesion: 0.11
Nodes (17): Bypassing the proxy, Compatible tools, Configuration, Documentation, GitHub Copilot, Google Gemini / Vertex AI, Headroom, How it works (+9 more)

### Community 5 - "AdeoTEK Scripting Best Practices (Strictly Enforced)"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 6 - "homebrew-install.sh"
Cohesion: 0.09
Nodes (12): Claude Code Plugin Marketplace, System Information Display Tool, base-tools-install.sh script, CLAUDECODE_PLUGINS, claude-code-setup.sh script, glow-install.sh script, neofetch-install.sh script, neofetch-setup.sh script (+4 more)

### Community 7 - "AGENTS.md — Operational Rules for AI Agents"
Cohesion: 0.22
Nodes (8): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents

### Community 8 - "yazi-install.sh"
Cohesion: 0.25
Nodes (3): rustup-install.sh script, yazi-setup.sh script, zellij-setup.sh script

### Community 9 - "wsl-setup-fedora-dev.sh"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 11 - "claude-code-install.sh"
Cohesion: 0.28
Nodes (6): AI Coding Tools (claude-code + opencode), claude-code-install.sh script, copy_files_if_missing(), opencode-install.sh script, copy_skills_if_missing(), opencode-setup.sh script

### Community 12 - "headroom-uninstall.sh"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 14 - "Run-LocalWinEnvSetup.ps1"
Cohesion: 0.67
Nodes (5): Add-Env-Path(), CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 15 - "tutor.md"
Cohesion: 0.50
Nodes (3): Core Principles, Response Style, When to Make Changes

### Community 16 - "Windows Network/Firewall Diagnostic Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 17 - "ghostty-install.sh"
Cohesion: 0.29
Nodes (3): ghostty-setup.sh script, zed-setup.sh script, Zed Editor settings.json

### Community 18 - "AGENTS.md (Coding Guidelines)"
Cohesion: 0.40
Nodes (5): GNU Stow Symlinking Pattern, Script Initialization Guard Pattern, AGENTS.md (Coding Guidelines), CLAUDE.md (Claude Code Instructions), README.md (Project Overview)

### Community 19 - "statusline-command.sh (Linux/WSL)"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 20 - "k8s-repo-install.sh"
Cohesion: 0.40
Nodes (3): Kubernetes Toolchain (kubectl + helm + k8s-repo), k8s-repo-install.sh script, kubectl-install.sh script

### Community 21 - "Neovim README.md"
Cohesion: 0.67
Nodes (3): Three Neovim Config Variants Pattern, Neovim Cheatsheet.md, Neovim README.md

### Community 22 - "oh-my-posh gbs.omp.yaml (Powerline Theme)"
Cohesion: 0.67
Nodes (3): Oh-My-Posh Theme Variants (icon vs text), oh-my-posh gbs.omp.yaml (Powerline Theme), oh-my-posh gbs-text.omp.yaml (Plain Theme)

### Community 23 - "cecho"
Cohesion: 0.12
Nodes (38): ansible-cleanup.sh script, aws-cli-install.sh script, dotnet-install.sh script, fastfetch-install.sh script, gcp-cli-install.sh script, ghostty-install.sh script, git-setup.sh script, github-cli-install.sh script (+30 more)

### Community 25 - "Dry-Run Safety Pattern"
Cohesion: 0.67
Nodes (3): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Rename-Files.ps1 (Bulk Rename with Dry-Run)

### Community 26 - "opencode: .NET Unit Test Expert Agent"
Cohesion: 0.67
Nodes (3): opencode: .NET Backend Expert Agent, opencode: .NET Unit Test Expert Agent, opencode: .NET Unit Testing Skill

### Community 27 - "adeotek_v1/plugins/lualine.lua (Statusline)"
Cohesion: 0.67
Nodes (3): jakoolit/plugins/lualine.lua (Statusline), adeotek_v1/plugins/catppuccin.lua (Theme), adeotek_v1/plugins/lualine.lua (Statusline)

### Community 29 - "cc-sessions.sh (Claude Code Session Browser)"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 30 - "ZSH README.md (Config Guide)"
Cohesion: 0.67
Nodes (3): ZSH Standalone Config (no plugin manager), zsh_plugins.txt (Plugin List), ZSH README.md (Config Guide)

### Community 34 - "opencode.json"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

### Community 35 - "_helpers.sh"
Cohesion: 0.15
Nodes (7): Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, git-install.sh script, aecho(), get_stow_command(), get_vv()

### Community 154 - "uv-install.sh (Python Package Manager)"
Cohesion: 0.18
Nodes (5): ansible-install.sh script, graphify-install.sh script, headroom-install.sh script, headroom-setup.sh script, uv-install.sh script

## Knowledge Gaps
- **135 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `_options.sh script`, `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS` (+130 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **31 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `cecho()` connect `cecho` to `system-update.sh`, `config.bash`, `_helpers.sh`, `homebrew-install.sh`, `yazi-install.sh`, `microsoft-repo-install.sh`, `claude-code-install.sh`, `k8s-repo-install.sh`, `hermes-install.sh`, `uv-install.sh (Python Package Manager)`, `docker-install.sh script`, `golang-install.sh`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **Why does `stow_package()` connect `cecho` to `config.bash`, `fastfetch-install.sh`, `_helpers.sh`, `tmux-install.sh`, `homebrew-install.sh`, `yazi-install.sh`, `ghostty-install.sh`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Why does `install_package()` connect `cecho` to `config.bash`, `_helpers.sh`, `tmux-install.sh`, `homebrew-install.sh`, `k8s-repo-install.sh`, `docker-install.sh script`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `_options.sh script` to the rest of the system?**
  _135 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `adeotek_v2/keymaps.lua (Centralized Keymaps)` be split into smaller, more focused modules?**
  _Cohesion score 0.05832147937411095 - nodes in this community are weakly interconnected._
- **Should `config.bash` be split into smaller, more focused modules?**
  _Cohesion score 0.0766488413547237 - nodes in this community are weakly interconnected._
- **Should `Hermes Agent` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._