# Graph Report - .dotfiles  (2026-09-14)

## Corpus Check
- 185 files · ~51,723 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 518 nodes · 709 edges · 108 communities (29 shown, 35 thin omitted)
- Extraction: 73% EXTRACTED · 27% INFERRED · 0% AMBIGUOUS · INFERRED: 189 edges (avg confidence: 0.62)
- Token cost: 11,200 input · 2,600 output

## Community Hubs (Navigation)
- Package Install Scripts
- Project Docs and Personas
- Shell Setup and Prompts
- Terminal Utilities
- Neovim Plugin Ecosystem
- AI Tool Installers
- Claude Statusline Scripts
- Multi-Distro Helpers
- Task Tier Arrays
- Headroom Provider Docs
- Neovim Config Router
- Dotfiles Agent Practices
- Infra Tool Installers
- WSL2 Setup Script
- Agent Operational Rules
- Claude Session Browsers
- OpenCode Config Merger
- Neovim Theme Docs
- Desktop Editors
- Kubernetes Toolchain
- OpenCode Subagent Rules
- Headroom Uninstall Script
- GitHub Stats Powershell
- Windows Env Setup
- Windows Network Tools
- Dotnet Expert Agents
- Tutor Agent Docs
- Hermes Install Scripts
- Tmux Setup Scripts
- Dry-Run Powershell Patterns
- Hermes Daily Update
- Neovim Statusline Plugins
- OpenCode Config Schema
- Graphify JS Plugin
- OpenCode Server Script
- TUI Theme Config
- Agent Orchestrators
- Docker Install Script
- Git Install and Setup
- Unattended Setup Flags
- Graphify Rules
- Graphify Workflow
- AI Config Bash
- Hermes Notify Script
- Toggleterm Plugins
- Oh My Posh Themes
- DevOps Agent
- Expert Agent Principles
- GitHub CLI and Stats
- Golang Install Script
- System Update Script
- Setup Entry Script
- Update Entry Script
- Homebrew Fallback
- Jakoolit Alpha Dashboard
- Jakoolit Neo-tree Explorer
- v1 Multi-cursor
- v2 Copilot Plugin
- v2 Gitsigns
- v2 Statusline
- v2 Keymap Discovery
- DevOps Primary Agent
- Tutor Agent Doc
- Tabby Terminal Config

## God Nodes (most connected - your core abstractions)
1. `cecho()` - 61 edges
2. `install_package()` - 29 edges
3. `decho()` - 28 edges
4. `stow_package()` - 21 edges
5. `Hermes Agent` - 11 edges
6. `Headroom` - 10 edges
7. `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles` - 10 edges
8. `AGENTS.md — Operational Rules for AI Agents` - 8 edges
9. `execute_command()` - 8 edges
10. `AdeoTEK Scripting Best Practices (Strictly Enforced)` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Global Claude Code Instructions (LSP-first navigation, playwright-cli)` --semantically_similar_to--> `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles`  [INFERRED] [semantically similar]
  claude-code/user-config/CLAUDE.md → AGENTS.md
- `Rename-Files.ps1 (Bulk Rename with Dry-Run)` --semantically_similar_to--> `Dry-Run Safety Pattern`  [INFERRED] [semantically similar]
  win-tools/.tools/Rename-Files.ps1 → _scripts/core/_helpers.sh
- `setup.sh (Interactive Setup)` --semantically_similar_to--> `unattended_setup.sh (Unattended Setup)`  [INFERRED] [semantically similar]
  setup.sh → unattended_setup.sh
- `graphify Always-On Rule (.agents/rules)` --semantically_similar_to--> `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles`  [INFERRED] [semantically similar]
  .agents/rules/graphify.md → AGENTS.md
- `Headroom Proxy (systemd user service, localhost:8787)` --semantically_similar_to--> `OpenCode Go Provider (deepseek-v4-flash primary)`  [INFERRED] [semantically similar]
  headroom/README.md → hermes/config.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **LSP Ecosystem (v2)** — nvim_config_nvim_lua_configs_adeotek_v2_plugins_lsp_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_bufferline, nvim_config_nvim_lua_configs_adeotek_v2_plugins_theme_v2, concept_lsp_ecosystem [EXTRACTED 1.00]
- **adeotek_v1 Initialization Chain** — nvim_config_nvim_init, nvim_config_nvim_lua_config, nvim_config_nvim_lua_configs_adeotek_v1_init, nvim_config_nvim_lua_configs_adeotek_v1_config, nvim_config_nvim_lua_configs_adeotek_v1_lazy_init, nvim_config_nvim_lua_configs_adeotek_v1_keymaps [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
- **AI Coding Tools** — scripts_core_claude_code_install, scripts_core_claude_code_setup, scripts_core_opencode_install, scripts_core_opencode_setup [INFERRED 0.85]
- **File Navigation & Fuzzy Find Cluster** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_telescope_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, nvim_config_nvim_lua_configs_adeotek_v1_plugins_neo_tree_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_nvim_tree_v2 [INFERRED 0.85]
- **adeotek_v1 UI Plugin Suite** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_catppuccin_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_lualine_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_bufferline, nvim_config_nvim_lua_configs_adeotek_v1_plugins_alpha_v1, nvim_config_nvim_lua_configs_adeotek_v1_plugins_nvim_scrollbar [INFERRED 0.85]
- **Setup-Wraps-Install Pattern** — scripts_core_fastfetch_setup, scripts_core_fastfetch_install, scripts_core_git_setup, scripts_core_git_install, scripts_core_jetbrains_toolbox_setup, scripts_core_jetbrains_toolbox_install [INFERRED 0.85]
- **Shell Prompt Tools with Nerd Fonts** — scripts_core_starship_install, scripts_core_oh_my_posh_install, scripts_core_nerd_fonts_install [INFERRED 0.85]
- **Theme Integration Cluster (catppuccin + dependents)** — nvim_config_nvim_lua_configs_adeotek_v2_plugins_theme_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_nvim_tree_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_lsp_v2, nvim_config_nvim_lua_configs_adeotek_v1_plugins_catppuccin_v1 [INFERRED 0.85]
- **Cross-Platform Claude Code Session Browsers** — tools_tools_cc_sessions, win_tools_get_cc_sessions [INFERRED 0.95]
- **Kubernetes Toolchain** — scripts_core_k8s_repo_install, scripts_core_kubectl_install, scripts_core_helm_install [INFERRED 0.95]
- **Claude Code Statusline Variants** — claude_code_user_config_statusline_command, claude_code_user_config_statusline_command_win, claude_code_user_config_statusline_slim [INFERRED 0.95]
- **Telescope Fuzzy Finder Across All Configs** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_telescope_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_telescope_v2, jakoolit_telescope [INFERRED 0.95]
- **Treesitter Across All Neovim Configs** — nvim_config_nvim_lua_configs_adeotek_v1_plugins_treesitter_v1, nvim_config_nvim_lua_configs_adeotek_v2_plugins_treesitter_v2, jakoolit_treesitter [INFERRED 0.95]
- **Windows Network & Firewall Tools** — win_tools_tools_add_winfirewallrule, win_tools_tools_get_winfirewallrulebyport, win_tools_run_port_listen, win_tools_run_port_probe [INFERRED 0.95]
- **Hermes persona/profile system (Mo & Foca personalities, Bot Chat protocol)** — hermes__hermes_soul_mo, hermes__hermes_profiles_foca_soul_foca, hermes_config, hermes__hermes_profiles_foca_config [INFERRED 0.95]
- **Duplicated agent coding-guideline layer (AGENTS.md mirrored into CLAUDE.md, dotfiles agent, global Claude config)** — agents, claude, _opencode_agents_dotfiles, claude_code_user_config_claude [INFERRED 0.85]
- **graphify knowledge-graph integration across agent instruction files** — agents, claude, _agents_rules_graphify, _agents_workflows_graphify, _opencode_agents_dotfiles [EXTRACTED 1.00]
- **OpenCode multi-agent roster** — opencode_agents_dev_agent, opencode_agents_expert_agent, opencode_agents_code_review_agent, opencode_agents_devops_agent, opencode_agents_tutor_agent, opencode_agents_dotnet_backend_expert_agent, opencode_agents_dotnet_unit_test_expert_agent [INFERRED 0.85]
- **xUnit/NSubstitute AAA testing practice** — opencode_agents_dotnet_unit_test_expert_agent, opencode_skills_dotnet_unit_testing_skill, opencode_agents_dotnet_unit_test_expert_aaa_pattern [INFERRED 0.85]
- **Neovim plugin configuration stack** — nvim__config_nvim_readme_doc, nvim__config_nvim_cheatsheet_doc, nvim__config_nvim_lua_configs_jakoolit_init_vim_config, nvim__config_nvim_readme_telescope, nvim__config_nvim_readme_neo_tree, nvim__config_nvim_readme_lualine, nvim__config_nvim_readme_catppuccin [INFERRED 0.80]

## Communities (108 total, 35 thin omitted)

### Community 0 - "Package Install Scripts"
Cohesion: 0.10
Nodes (39): ansible-cleanup.sh script, aws-cli-install.sh script, dotnet-install.sh script, fastfetch-install.sh script, gcp-cli-install.sh script, ghostty-install.sh script, git-setup.sh script, github-cli-install.sh script (+31 more)

### Community 1 - "Project Docs and Personas"
Cohesion: 0.07
Nodes (38): graphify Always-On Rule (.agents/rules), graphify Workflow (/graphify command), .opencode/agents/dotfiles.md — Dotfiles Agent Definition, Dotfiles Expert Agent (OpenCode subagent), AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles, GNU Stow Symlink Configuration Management, Script Initialization Guard Pattern (RDIR/CDIR/_helpers.sh), Task Array Tier Hierarchy (MINIMAL → ALL_TASKS) (+30 more)

### Community 2 - "Shell Setup and Prompts"
Cohesion: 0.08
Nodes (19): config.bash script, COLORTERM, EDITOR, LC_ALL, PATH, Shell PATH Setup (Homebrew/Rust/Go/dotnet), Install-Then-Setup Pattern, Shell Prompt Customization Tool (+11 more)

### Community 3 - "Terminal Utilities"
Cohesion: 0.09
Nodes (11): System Information Display Tool, base-tools-install.sh script, glow-install.sh script, neofetch-install.sh script, neofetch-setup.sh script, rtk-install.sh script, rtk-setup.sh script, rustup-install.sh script (+3 more)

### Community 4 - "Neovim Plugin Ecosystem"
Cohesion: 0.10
Nodes (18): Centralized Keymap Architecture (v2 pattern), LSP Ecosystem (lspconfig + mason + cmp + LuaSnip), Theme Integration Pattern (catppuccin integrations), jakoolit/plugins/catppuccin.lua (Theme), jakoolit/plugins/lsp-config.lua (LSP), jakoolit/plugins/telescope.lua (Fuzzy Finder), jakoolit/plugins/treesitter.lua (Syntax), adeotek_v1/plugins/alpha.lua (Dashboard) (+10 more)

### Community 5 - "AI Tool Installers"
Cohesion: 0.11
Nodes (12): AI Coding Tools (claude-code + opencode), Claude Code Plugin Marketplace, claude-code-install.sh script, CLAUDECODE_PLUGINS, claude-code-setup.sh script, copy_files_if_missing(), nvim-setup.sh script, opencode-install.sh script (+4 more)

### Community 6 - "Claude Statusline Scripts"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 7 - "Multi-Distro Helpers"
Cohesion: 0.12
Nodes (9): Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, fastfetch-setup.sh script, aecho(), get_stow_command(), get_vv(), jetbrains-toolbox-setup.sh script (+1 more)

### Community 8 - "Task Tier Arrays"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 9 - "Headroom Provider Docs"
Cohesion: 0.12
Nodes (17): Bypassing the proxy, Compatible tools, Configuration, Documentation, GitHub Copilot, Google Gemini / Vertex AI, Headroom, How it works (+9 more)

### Community 10 - "Neovim Config Router"
Cohesion: 0.14
Nodes (3): lazy.nvim Plugin Manager, NVIM_CONFIG Env Var Config Router, adeotek_v1/plugins/init.lua (Plugin List)

### Community 11 - "Dotfiles Agent Practices"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 12 - "Infra Tool Installers"
Cohesion: 0.18
Nodes (5): ansible-install.sh script, graphify-install.sh script, headroom-install.sh script, headroom-setup.sh script, uv-install.sh script

### Community 13 - "WSL2 Setup Script"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 14 - "Agent Operational Rules"
Cohesion: 0.22
Nodes (8): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents

### Community 15 - "Claude Session Browsers"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 16 - "OpenCode Config Merger"
Cohesion: 0.36
Nodes (7): _key(), main(), merge(), Merge a template opencode config into an existing live config. Used by…, Remove // and /* */ comments outside strings (state machine)., Deep merge: live-only content kept; conflict winner depends on mode., strip_jsonc()

### Community 17 - "Neovim Theme Docs"
Cohesion: 0.38
Nodes (7): Neovim Cheatsheet, jakoolit init.vim config, Catppuccin.nvim theme, AdeoTEK Neovim configuration README, lualine.nvim plugin, Neo-tree.nvim plugin, telescope.nvim plugin

### Community 18 - "Desktop Editors"
Cohesion: 0.29
Nodes (3): ghostty-setup.sh script, zed-setup.sh script, Zed Editor settings.json

### Community 19 - "Kubernetes Toolchain"
Cohesion: 0.40
Nodes (3): Kubernetes Toolchain (kubectl + helm + k8s-repo), k8s-repo-install.sh script, kubectl-install.sh script

### Community 20 - "OpenCode Subagent Rules"
Cohesion: 0.40
Nodes (6): code-review subagent, dev primary agent, expert build/orchestrator agent, Git Commit Policy (explicit per-commit approval), Prefer LSP over Grep/Glob for navigation, Verification Before Done

### Community 21 - "Headroom Uninstall Script"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 23 - "Windows Env Setup"
Cohesion: 0.67
Nodes (5): Add-Env-Path(), CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 24 - "Windows Network Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 25 - "Dotnet Expert Agents"
Cohesion: 0.50
Nodes (5): dotnet-backend-expert agent, Minimal API pattern (NOT controllers), Arrange-Act-Assert (AAA) pattern, dotnet-unit-test-expert agent, dotnet-unit-testing skill

### Community 26 - "Tutor Agent Docs"
Cohesion: 0.50
Nodes (3): Core Principles, Response Style, When to Make Changes

### Community 29 - "Dry-Run Powershell Patterns"
Cohesion: 0.67
Nodes (3): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Rename-Files.ps1 (Bulk Rename with Dry-Run)

### Community 31 - "Neovim Statusline Plugins"
Cohesion: 0.67
Nodes (3): jakoolit/plugins/lualine.lua (Statusline), adeotek_v1/plugins/catppuccin.lua (Theme), adeotek_v1/plugins/lualine.lua (Statusline)

### Community 36 - "Agent Orchestrators"
Cohesion: 0.67
Nodes (3): Claude Code CLI (orchestrated agent), Paseo agent-orchestrator daemon, Hermes via ACP provider

## Knowledge Gaps
- **127 isolated node(s):** `Core Principles`, `Response Style`, `When to Make Changes`, `Architecture`, `config.yaml` (+122 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 205 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **35 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `cecho()` connect `Package Install Scripts` to `Shell Setup and Prompts`, `Terminal Utilities`, `Docker Install Script`, `AI Tool Installers`, `Multi-Distro Helpers`, `Infra Tool Installers`, `Golang Install Script`, `Kubernetes Toolchain`, `System Update Script`, `Hermes Install Scripts`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Why does `install_package()` connect `Package Install Scripts` to `Shell Setup and Prompts`, `Terminal Utilities`, `Docker Install Script`, `Git Install and Setup`, `Multi-Distro Helpers`, `Kubernetes Toolchain`, `Tmux Setup Scripts`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `stow_package()` connect `Package Install Scripts` to `Shell Setup and Prompts`, `Terminal Utilities`, `AI Tool Installers`, `Multi-Distro Helpers`, `Desktop Editors`, `Tmux Setup Scripts`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **What connects `Core Principles`, `Response Style`, `When to Make Changes` to the rest of the system?**
  _127 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Package Install Scripts` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Project Docs and Personas` be split into smaller, more focused modules?**
  _Cohesion score 0.06923076923076923 - nodes in this community are weakly interconnected._
- **Should `Shell Setup and Prompts` be split into smaller, more focused modules?**
  _Cohesion score 0.07954545454545454 - nodes in this community are weakly interconnected._