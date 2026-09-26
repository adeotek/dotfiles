# Graph Report - .dotfiles  (2026-09-26)

## Corpus Check
- 150 files · ~59,728 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 484 nodes · 740 edges · 62 communities (27 shown, 35 thin omitted)
- Extraction: 76% EXTRACTED · 24% INFERRED · 0% AMBIGUOUS · INFERRED: 180 edges (avg confidence: 0.62)
- Token cost: 14,200 input · 3,600 output

## Community Hubs (Navigation)
- Per-Tool Install Scripts (CLI/Dev Apps)
- Core Toolchain Installs
- AI Agent Configs & Services
- Shell & Terminal Appearance Setups
- Statusline Scripts
- Package Tier System (_options)
- Config Merge Utilities
- pi-lens Config Keys
- Agent Operational Rules
- Permission System Config
- AI Coding Tool Installs
- Scripting Best Practices Doc
- Bash Shell Config
- WSL2 Fedora Setup
- Neovim Core Config
- Session Browser Tools
- Neovim LSP Stack
- Kubernetes Toolchain
- Pi Install & Setup
- Dotnet Unit Testing
- Windows PowerShell Helpers
- Headroom Uninstall
- Interactive Setup Menu
- GitHub Stats PowerShell
- Windows Firewall Tools
- Pi Code Review Agents
- Pi Tutor Agent
- Graphify OpenCode Plugin
- Fastfetch Setup
- Hermes Update Scripts
- Neovim Mini Plugins
- Treesitter Setup
- Pi DevOps Agent
- Dotnet Backend Expert
- OpenCode JSON Schema
- OpenCode Server Launcher
- TUI Theme Config
- Unattended Setup Entry
- AI Config Shell
- Neovim Theme
- Hermes Notify
- Oh My Posh Themes
- System Update Entry
- Homebrew Fallback
- Tabby Config
- ZSH Plugin Manifest

## God Nodes (most connected - your core abstractions)
1. `cecho()` - 69 edges
2. `install_package()` - 31 edges
3. `decho()` - 22 edges
4. `stow_package()` - 22 edges
5. `execute_command()` - 12 edges
6. `read_yes_no()` - 9 edges
7. `Dotfiles README` - 9 edges
8. `AGENTS.md — Operational Rules for AI Agents` - 8 edges
9. `AdeoTEK Scripting Best Practices (Strictly Enforced)` - 7 edges
10. `statusline-command-win.sh script` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Rename-Files.ps1 (Bulk Rename with Dry-Run)` --semantically_similar_to--> `Dry-Run Safety Pattern`  [INFERRED] [semantically similar]
  win-tools/.tools/Rename-Files.ps1 → _scripts/core/_helpers.sh
- `setup.sh (Interactive Setup)` --semantically_similar_to--> `unattended_setup.sh (Unattended Setup)`  [INFERRED] [semantically similar]
  setup.sh → unattended_setup.sh
- `Global Claude Code Instructions (LSP-first navigation, playwright-cli)` --semantically_similar_to--> `AGENTS.md (project agent guidelines)`  [INFERRED] [semantically similar]
  claude-code/user-config/CLAUDE.md → AGENTS.md
- `Zed config documentation` --references--> `Zed settings.json (stowed)`  [INFERRED]
  docs/zed.md → .zed/settings.json
- `.NET Backend Expert Agent (opencode)` --semantically_similar_to--> `.NET Backend Expert Subagent (pi)`  [INFERRED] [semantically similar]
  opencode/agents/dotnet-backend-expert.md → pi/agents/dotnet-backend-expert.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
- **AI Coding Tools** — scripts_core_claude_code_install, scripts_core_claude_code_setup, scripts_core_opencode_install, scripts_core_opencode_setup [INFERRED 0.85]
- **Setup-Wraps-Install Pattern** — scripts_core_fastfetch_setup, scripts_core_fastfetch_install, scripts_core_git_setup, scripts_core_git_install, scripts_core_jetbrains_toolbox_setup, scripts_core_jetbrains_toolbox_install [INFERRED 0.85]
- **Shell Prompt Tools with Nerd Fonts** — scripts_core_starship_install, scripts_core_oh_my_posh_install, scripts_core_nerd_fonts_install [INFERRED 0.85]
- **Cross-Platform Claude Code Session Browsers** — tools_tools_cc_sessions, win_tools_get_cc_sessions [INFERRED 0.95]
- **Kubernetes Toolchain** — scripts_core_k8s_repo_install, scripts_core_kubectl_install, scripts_core_helm_install [INFERRED 0.95]
- **Claude Code Statusline Variants** — claude_code_user_config_statusline_command, claude_code_user_config_statusline_command_win, claude_code_user_config_statusline_slim [INFERRED 0.95]
- **Windows Network & Firewall Tools** — win_tools_tools_add_winfirewallrule, win_tools_tools_get_winfirewallrulebyport, win_tools_run_port_listen, win_tools_run_port_probe [INFERRED 0.95]
- **AI agent tooling and proxy stack** — docs_headroom_headroom, docs_hermes_hermes_agent, docs_paseo_paseo_daemon, _opencode_opencode, docs_zed_acp_agent_integration [INFERRED 0.85]
- **Hermes multi-agent persona and agent-to-agent messaging protocol** — hermes__hermes_soul, hermes__hermes_profiles_foca_soul, hermes_config, hermes__hermes_profiles_foca_config [EXTRACTED 0.95]
- **Multi-distro GNU Stow deployment flow** — readme_gnu_stow, readme_package_tiers, agents, _opencode_agents_dotfiles_scripting_conventions [EXTRACTED 0.90]
- **Pi Agent Set Ported from OpenCode Definitions** — pi_agents_code_review, pi_agents_devops, pi_agents_dotnet_backend_expert, pi_agents_dotnet_unit_test_expert, pi_agents_expert, pi_agents_tutor, opencode_agents_code_review, opencode_agents_devops, opencode_agents_dotnet_backend_expert, opencode_agents_dotnet_unit_test_expert, opencode_agents_expert, opencode_agents_tutor [INFERRED 0.85]
- **Pi Agent System Prompt Assembly (global rules + appended system)** — pi_agents, pi_append_system, pi_agents_code_review, pi_agents_expert [INFERRED 0.85]
- **dotnet-unit-testing Skill Chain (xUnit/NSubstitute tooling)** — opencode_skills_dotnet_unit_testing_skill, pi_skills_dotnet_unit_testing_skill, opencode_agents_dotnet_unit_test_expert, pi_agents_dotnet_unit_test_expert, opencode_skills_dotnet_unit_testing_skill_arrange_act_assert, opencode_skills_dotnet_unit_testing_skill_nsubstitute_mocking [INFERRED 0.85]

## Communities (62 total, 35 thin omitted)

### Community 0 - "Per-Tool Install Scripts (CLI/Dev Apps)"
Cohesion: 0.05
Nodes (51): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, Terminal Emulator, ansible-cleanup.sh script, ansible-install.sh script (+43 more)

### Community 1 - "Core Toolchain Installs"
Cohesion: 0.06
Nodes (22): base-tools-install.sh script, dotnet-install.sh script, github-cli-install.sh script, glow-install.sh script, install_package(), HOMEBREW_NO_ASK, homebrew-install.sh script, lsp-servers-install.sh script (+14 more)

### Community 2 - "AI Agent Configs & Services"
Cohesion: 0.07
Nodes (34): Dotfiles Agent (OpenCode subagent definition), Graphify knowledge-graph tool, AdeoTEK Bash scripting conventions, OpenCode global config (opencode.json), Graphify OpenCode plugin (.opencode/plugins/graphify.js), Zed settings.json (stowed), AGENTS.md (project agent guidelines), Global Claude Code Instructions (LSP-first navigation, playwright-cli) (+26 more)

### Community 3 - "Shell & Terminal Appearance Setups"
Cohesion: 0.09
Nodes (20): Install-Then-Setup Pattern, Shell Prompt Customization Tool, bash-setup.sh script, ghostty-setup.sh script, process_args(), rename_dir_if_exists(), _helpers.sh script, stow_package() (+12 more)

### Community 4 - "Statusline Scripts"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 5 - "Package Tier System (_options)"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 6 - "Config Merge Utilities"
Cohesion: 0.18
Nodes (17): json, _key(), main(), merge(), Merge a template opencode config into an existing live config. Used by…, strip_jsonc(), os, _key() (+9 more)

### Community 7 - "pi-lens Config Keys"
Cohesion: 0.12
Nodes (15): autofix, enabled, contextInjection, enabled, format, enabled, mode, ignore (+7 more)

### Community 8 - "Agent Operational Rules"
Cohesion: 0.18
Nodes (13): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents (+5 more)

### Community 9 - "Permission System Config"
Cohesion: 0.15
Nodes (12): git commit *, git push *, rm *, sudo *, *.env, *.env.example, next-env.d.ts, permission (+4 more)

### Community 10 - "AI Coding Tool Installs"
Cohesion: 0.18
Nodes (8): AI Coding Tools (claude-code + opencode), Claude Code Plugin Marketplace, claude-code-install.sh script, CLAUDECODE_PLUGINS, claude-code-setup.sh script, opencode-install.sh script, playwright-install.sh script, Run-LocalWinEnvSetup.ps1 (Windows Dev Setup)

### Community 11 - "Scripting Best Practices Doc"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 12 - "Bash Shell Config"
Cohesion: 0.24
Nodes (7): config.bash script, COLORTERM, EDITOR, LC_ALL, path_append(), path_prepend(), Shell PATH Setup (Homebrew/Rust/Go/dotnet)

### Community 13 - "WSL2 Fedora Setup"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 15 - "Session Browser Tools"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 16 - "Neovim LSP Stack"
Cohesion: 0.29
Nodes (5): blink_cmp, luasnip_loaders_from_vscode, mason, mason_lspconfig, mason_tool_installer

### Community 17 - "Kubernetes Toolchain"
Cohesion: 0.33
Nodes (4): Kubernetes Toolchain (kubectl + helm + k8s-repo), helm-install.sh script, k8s-repo-install.sh script, kubectl-install.sh script

### Community 18 - "Pi Install & Setup"
Cohesion: 0.43
Nodes (5): pi_node_ok(), pi-install.sh script, copy_agents_if_missing(), copy_skills_if_missing(), pi-setup.sh script

### Community 19 - "Dotnet Unit Testing"
Cohesion: 0.67
Nodes (6): .NET Unit Test Expert Agent (opencode), dotnet-unit-testing Skill (opencode), Arrange-Act-Assert (AAA) Test Pattern, NSubstitute Interface Mocking (Substitute.For, Arg matchers), .NET Unit Test Expert Subagent (pi), dotnet-unit-testing Skill (pi)

### Community 20 - "Windows PowerShell Helpers"
Cohesion: 0.60
Nodes (5): powershell_yaml, CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 21 - "Headroom Uninstall"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 22 - "Interactive Setup Menu"
Cohesion: 0.60
Nodes (5): _render_grid(), _render_menu(), select_packages_grid(), setup.sh script, show_usage()

### Community 24 - "Windows Firewall Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 25 - "Pi Code Review Agents"
Cohesion: 0.50
Nodes (3): Core Principles, Code Review Subagent (pi), Build/Orchestrator Subagent (pi)

### Community 26 - "Pi Tutor Agent"
Cohesion: 0.40
Nodes (4): Core Principles, Response Style, When to Make Changes, Guided Learning Tutor Subagent (pi)

### Community 27 - "Graphify OpenCode Plugin"
Cohesion: 0.40
Nodes (3): IMPORTANT: keep the reminder string free of backticks and $(...) constructs., ref_fs, ref_path

### Community 33 - "Dotnet Backend Expert"
Cohesion: 1.00
Nodes (3): .NET Backend Expert Agent (opencode), Minimal API Pattern over MVC Controllers, .NET Backend Expert Subagent (pi)

## Knowledge Gaps
- **99 isolated node(s):** `1. Robust Conditional Logic`, `2. Error Handling & Indentation`, `3. Function & Variable Scoping`, `4. Output & Logging Helpers`, `5. Side-Effect Guarding (Dry Runs)` (+94 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 153 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **35 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `cecho()` connect `Per-Tool Install Scripts (CLI/Dev Apps)` to `Core Toolchain Installs`, `Shell & Terminal Appearance Setups`, `AI Coding Tool Installs`, `Kubernetes Toolchain`, `Pi Install & Setup`, `Fastfetch Setup`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `install_package()` connect `Core Toolchain Installs` to `Per-Tool Install Scripts (CLI/Dev Apps)`, `Kubernetes Toolchain`, `Shell & Terminal Appearance Setups`, `Fastfetch Setup`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `stow_package()` connect `Shell & Terminal Appearance Setups` to `Per-Tool Install Scripts (CLI/Dev Apps)`, `Core Toolchain Installs`, `Fastfetch Setup`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `1. Robust Conditional Logic`, `2. Error Handling & Indentation`, `3. Function & Variable Scoping` to the rest of the system?**
  _99 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Per-Tool Install Scripts (CLI/Dev Apps)` be split into smaller, more focused modules?**
  _Cohesion score 0.050949367088607596 - nodes in this community are weakly interconnected._
- **Should `Core Toolchain Installs` be split into smaller, more focused modules?**
  _Cohesion score 0.0627177700348432 - nodes in this community are weakly interconnected._
- **Should `AI Agent Configs & Services` be split into smaller, more focused modules?**
  _Cohesion score 0.0748663101604278 - nodes in this community are weakly interconnected._