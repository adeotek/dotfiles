# Graph Report - .dotfiles  (2026-09-16)

## Corpus Check
- 179 files · ~60,790 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 43 file(s) not represented in the graph (top: (none) 7, .toml 7, .service 6)

## Summary
- 514 nodes · 696 edges · 118 communities (33 shown, 34 thin omitted)
- Extraction: 75% EXTRACTED · 25% INFERRED · 0% AMBIGUOUS · INFERRED: 174 edges (avg confidence: 0.61)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ffc72b9a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- cecho
- Hermes Agent
- homebrew-install.sh
- yazi-install.sh
- adeotek_v2/keymaps.lua
- claude-code-setup.sh
- statusline-command.sh
- _helpers.sh
- _options.sh
- AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles
- lua/config.lua
- AdeoTEK Scripting Best Practices (Strictly Enforced)
- uv-install.sh
- wsl-setup-fedora-dev.sh
- AGENTS.md — Operational Rules for AI Agents
- cc-sessions.sh
- merge
- AdeoTEK Neovim configuration README
- Headroom
- k8s-repo-install.sh
- expert build/orchestrator agent
- headroom-uninstall.sh
- Get-GitHubStats.ps1
- Run-LocalWinEnvSetup.ps1
- Windows Network/Firewall Diagnostic Tools
- dotnet-unit-test-expert agent
- tutor.md
- config.bash
- tmux-install.sh
- Dry-Run Safety Pattern
- hermes-update-daily.sh
- Full Repository Review — AdeoTEK Dotfiles
- opencode.json
- graphify.js
- start-opencode-server.sh
- tui.json
- Paseo agent-orchestrator daemon
- docker-install.sh script
- ghostty-install.sh
- unattended_setup.sh
- rules/graphify.md
- workflows/graphify.md
- ai-config.bash
- hermes-update-notify.sh
- adeotek_v2/plugins/toggleterm.lua (Terminal)
- gbs Oh My Posh theme
- devops.md
- expert.md
- github-cli-install.sh
- Zed — stowed config + setup notes
- herdr-setup.sh
- setup.sh
- update.sh
- Homebrew Fallback Package Manager
- git-install.sh
- fastfetch-install.sh
- jetbrains-toolbox-install.sh
- mise-install.sh
- adeotek_v2/plugins/copilot.lua (GitHub Copilot)
- adeotek_v2/plugins/git.lua (Gitsigns)
- adeotek_v2/plugins/lualine.lua (Statusline)
- adeotek_v2/plugins/which-key.lua (Keymap Discovery)
- devops primary agent
- tutor agent
- Tabby terminal config
- adeotek_v2/plugins/treesitter.lua (Syntax)
- golang-install.sh

## God Nodes (most connected - your core abstractions)
1. `cecho()` - 63 edges
2. `install_package()` - 31 edges
3. `decho()` - 24 edges
4. `stow_package()` - 22 edges
5. `Full Repository Review — AdeoTEK Dotfiles` - 12 edges
6. `Hermes Agent` - 11 edges
7. `execute_command()` - 10 edges
8. `Headroom` - 10 edges
9. `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles` - 10 edges
10. `AGENTS.md — Operational Rules for AI Agents` - 8 edges

## Surprising Connections (you probably didn't know these)
- `Global Claude Code Instructions (LSP-first navigation, playwright-cli)` --semantically_similar_to--> `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles`  [INFERRED] [semantically similar]
  claude-code/user-config/CLAUDE.md → AGENTS.md
- `Headroom Proxy (systemd user service, localhost:8787)` --semantically_similar_to--> `OpenCode Go Provider (deepseek-v4-flash primary)`  [INFERRED] [semantically similar]
  headroom/README.md → hermes/config.yaml
- `Rename-Files.ps1 (Bulk Rename with Dry-Run)` --semantically_similar_to--> `Dry-Run Safety Pattern`  [INFERRED] [semantically similar]
  win-tools/.tools/Rename-Files.ps1 → _scripts/core/_helpers.sh
- `setup.sh (Interactive Setup)` --semantically_similar_to--> `unattended_setup.sh (Unattended Setup)`  [INFERRED] [semantically similar]
  setup.sh → unattended_setup.sh
- `graphify Always-On Rule (.agents/rules)` --semantically_similar_to--> `AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles`  [INFERRED] [semantically similar]
  .agents/rules/graphify.md → AGENTS.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **graphify knowledge-graph integration across agent instruction files** — agents, claude, _agents_rules_graphify, _agents_workflows_graphify, _opencode_agents_dotfiles [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **LSP Ecosystem (v2)** — nvim_config_nvim_lua_configs_adeotek_v2_plugins_lsp_v2, nvim_config_nvim_lua_configs_adeotek_v2_plugins_bufferline, nvim_config_nvim_lua_configs_adeotek_v2_plugins_theme_v2, concept_lsp_ecosystem [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
- **Duplicated agent coding-guideline layer (AGENTS.md mirrored into CLAUDE.md, dotfiles agent, global Claude config)** — agents, claude, _opencode_agents_dotfiles, claude_code_user_config_claude [INFERRED 0.85]
- **AI Coding Tools** — scripts_core_claude_code_install, scripts_core_claude_code_setup, scripts_core_opencode_install, scripts_core_opencode_setup [INFERRED 0.85]
- **xUnit/NSubstitute AAA testing practice** — opencode_agents_dotnet_unit_test_expert_agent, opencode_skills_dotnet_unit_testing_skill, opencode_agents_dotnet_unit_test_expert_aaa_pattern [INFERRED 0.85]
- **OpenCode multi-agent roster** — opencode_agents_dev_agent, opencode_agents_expert_agent, opencode_agents_code_review_agent, opencode_agents_devops_agent, opencode_agents_tutor_agent, opencode_agents_dotnet_backend_expert_agent, opencode_agents_dotnet_unit_test_expert_agent [INFERRED 0.85]
- **Setup-Wraps-Install Pattern** — scripts_core_fastfetch_setup, scripts_core_fastfetch_install, scripts_core_git_setup, scripts_core_git_install, scripts_core_jetbrains_toolbox_setup, scripts_core_jetbrains_toolbox_install [INFERRED 0.85]
- **Shell Prompt Tools with Nerd Fonts** — scripts_core_starship_install, scripts_core_oh_my_posh_install, scripts_core_nerd_fonts_install [INFERRED 0.85]
- **Cross-Platform Claude Code Session Browsers** — tools_tools_cc_sessions, win_tools_get_cc_sessions [INFERRED 0.95]
- **Hermes persona/profile system (Mo & Foca personalities, Bot Chat protocol)** — hermes__hermes_soul_mo, hermes__hermes_profiles_foca_soul_foca, hermes_config, hermes__hermes_profiles_foca_config [INFERRED 0.95]
- **Kubernetes Toolchain** — scripts_core_k8s_repo_install, scripts_core_kubectl_install, scripts_core_helm_install [INFERRED 0.95]
- **Claude Code Statusline Variants** — claude_code_user_config_statusline_command, claude_code_user_config_statusline_command_win, claude_code_user_config_statusline_slim [INFERRED 0.95]
- **Windows Network & Firewall Tools** — win_tools_tools_add_winfirewallrule, win_tools_tools_get_winfirewallrulebyport, win_tools_run_port_listen, win_tools_run_port_probe [INFERRED 0.95]

## Communities (118 total, 34 thin omitted)

### Community 0 - "cecho"
Cohesion: 0.11
Nodes (42): ansible-cleanup.sh script, aws-cli-install.sh script, bash-setup.sh script, dotnet-install.sh script, fastfetch-install.sh script, gcp-cli-install.sh script, ghostty-install.sh script, git-setup.sh script (+34 more)

### Community 1 - "Hermes Agent"
Cohesion: 0.08
Nodes (27): Headroom Proxy (systemd user service, localhost:8787), Foca Profile config.yaml (deployed ~/.hermes/profiles/foca), Foca — Senior Engineer/Architect Persona (profile SOUL.md), Mo — Hermes Maintainer Persona (SOUL.md), hermes/config.yaml — Hermes Master Config Template, Hermes Fallback Provider Chain, OpenCode Go Provider (deepseek-v4-flash primary), API Server (port 8642) (+19 more)

### Community 2 - "homebrew-install.sh"
Cohesion: 0.08
Nodes (14): Install-Then-Setup Pattern, Shell Prompt Customization Tool, Terminal Emulator, base-tools-install.sh script, glow-install.sh script, kitty-setup.sh script, nvim-setup.sh script, oh-my-posh-setup.sh script (+6 more)

### Community 3 - "yazi-install.sh"
Cohesion: 0.25
Nodes (3): rustup-install.sh script, yazi-setup.sh script, zellij-setup.sh script

### Community 4 - "adeotek_v2/keymaps.lua"
Cohesion: 0.16
Nodes (8): Centralized Keymap Architecture (v2 pattern), LSP Ecosystem (lspconfig + mason + cmp + LuaSnip), Theme Integration Pattern (catppuccin integrations), adeotek_v2/plugins/alpha.lua (Dashboard), adeotek_v2/plugins/lsp.lua (LSP + Mason + nvim-cmp), adeotek_v2/plugins/nvim-tree.lua (File Explorer), adeotek_v2/plugins/telescope.lua (Fuzzy Finder), adeotek_v2/plugins/theme.lua (Catppuccin)

### Community 5 - "claude-code-setup.sh"
Cohesion: 0.10
Nodes (13): AI Coding Tools (claude-code + opencode), Claude Code Plugin Marketplace, claude-code-install.sh script, CLAUDECODE_PLUGINS, claude-code-setup.sh script, copy_files_if_missing(), hermes-install.sh script, hermes-setup.sh script (+5 more)

### Community 6 - "statusline-command.sh"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 7 - "_helpers.sh"
Cohesion: 0.16
Nodes (6): Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, aecho(), get_stow_command(), get_vv()

### Community 8 - "_options.sh"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 9 - "AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles"
Cohesion: 0.23
Nodes (14): graphify Always-On Rule (.agents/rules), graphify Workflow (/graphify command), .opencode/agents/dotfiles.md — Dotfiles Agent Definition, Dotfiles Expert Agent (OpenCode subagent), AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles, GNU Stow Symlink Configuration Management, Script Initialization Guard Pattern (RDIR/CDIR/_helpers.sh), Task Array Tier Hierarchy (MINIMAL → ALL_TASKS) (+6 more)

### Community 11 - "AdeoTEK Scripting Best Practices (Strictly Enforced)"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 12 - "uv-install.sh"
Cohesion: 0.29
Nodes (3): ansible-install.sh script, graphify-install.sh script, uv-install.sh script

### Community 13 - "wsl-setup-fedora-dev.sh"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 14 - "AGENTS.md — Operational Rules for AI Agents"
Cohesion: 0.22
Nodes (8): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents

### Community 15 - "cc-sessions.sh"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 16 - "merge"
Cohesion: 0.39
Nodes (7): _key(), main(), merge(), Merge a template opencode config into an existing live config. Used by…, Remove // and /* */ comments outside strings (state machine)., Deep merge: live-only content kept; conflict winner depends on mode., strip_jsonc()

### Community 17 - "AdeoTEK Neovim configuration README"
Cohesion: 0.40
Nodes (6): Neovim Cheatsheet, Catppuccin.nvim theme, AdeoTEK Neovim configuration README, lualine.nvim plugin, Neo-tree.nvim plugin, telescope.nvim plugin

### Community 18 - "Headroom"
Cohesion: 0.12
Nodes (17): Bypassing the proxy, Compatible tools, Configuration, Documentation, GitHub Copilot, Google Gemini / Vertex AI, Headroom, How it works (+9 more)

### Community 19 - "k8s-repo-install.sh"
Cohesion: 0.40
Nodes (3): Kubernetes Toolchain (kubectl + helm + k8s-repo), k8s-repo-install.sh script, kubectl-install.sh script

### Community 20 - "expert build/orchestrator agent"
Cohesion: 0.40
Nodes (6): code-review subagent, dev primary agent, expert build/orchestrator agent, Git Commit Policy (explicit per-commit approval), Prefer LSP over Grep/Glob for navigation, Verification Before Done

### Community 21 - "headroom-uninstall.sh"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 23 - "Run-LocalWinEnvSetup.ps1"
Cohesion: 0.80
Nodes (4): CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 24 - "Windows Network/Firewall Diagnostic Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 25 - "dotnet-unit-test-expert agent"
Cohesion: 0.50
Nodes (5): dotnet-backend-expert agent, Minimal API pattern (NOT controllers), Arrange-Act-Assert (AAA) pattern, dotnet-unit-test-expert agent, dotnet-unit-testing skill

### Community 26 - "tutor.md"
Cohesion: 0.50
Nodes (3): Core Principles, Response Style, When to Make Changes

### Community 27 - "config.bash"
Cohesion: 0.24
Nodes (7): config.bash script, COLORTERM, EDITOR, LC_ALL, path_append(), path_prepend(), Shell PATH Setup (Homebrew/Rust/Go/dotnet)

### Community 29 - "Dry-Run Safety Pattern"
Cohesion: 0.67
Nodes (3): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Rename-Files.ps1 (Bulk Rename with Dry-Run)

### Community 31 - "Full Repository Review — AdeoTEK Dotfiles"
Cohesion: 0.15
Nodes (12): A. Entry points, shared helpers, options, B. Install scripts (`_scripts/core/*_install.sh`), C. Setup & deploy scripts (`*_setup.sh` + specials), D. Dotfile configs, E. Tools / PowerShell / opencode tooling, F. Over-engineering scan (ponytail audit), Full Repository Review — AdeoTEK Dotfiles, G. Shellcheck baseline — false positives / vendored (no action) (+4 more)

### Community 36 - "Paseo agent-orchestrator daemon"
Cohesion: 0.67
Nodes (3): Claude Code CLI (orchestrated agent), Paseo agent-orchestrator daemon, Hermes via ACP provider

### Community 37 - "docker-install.sh script"
Cohesion: 0.29
Nodes (4): docker-install.sh script, headroom-install.sh script, headroom-setup.sh script, enable_wsl_systemd()

### Community 38 - "ghostty-install.sh"
Cohesion: 0.29
Nodes (3): ghostty-setup.sh script, zed-setup.sh script, Zed Editor settings.json

### Community 50 - "Zed — stowed config + setup notes"
Cohesion: 0.40
Nodes (4): House rules, Per-machine setup (not stowable — do once per machine), What `settings.json` contains, Zed — stowed config + setup notes

### Community 51 - "herdr-setup.sh"
Cohesion: 0.50
Nodes (3): herdr-install.sh script, setup_herdr_completions(), herdr-setup.sh script

## Knowledge Gaps
- **136 isolated node(s):** `$schema`, `plugin`, `_options.sh script`, `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS` (+131 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 221 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **34 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `cecho()` connect `cecho` to `homebrew-install.sh`, `yazi-install.sh`, `docker-install.sh script`, `claude-code-setup.sh`, `_helpers.sh`, `uv-install.sh`, `herdr-setup.sh`, `k8s-repo-install.sh`, `golang-install.sh`, `mise-install.sh`?**
  _High betweenness centrality (0.040) - this node is a cross-community bridge._
- **Why does `install_package()` connect `cecho` to `homebrew-install.sh`, `docker-install.sh script`, `_helpers.sh`, `k8s-repo-install.sh`, `git-install.sh`, `tmux-install.sh`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Why does `stow_package()` connect `cecho` to `homebrew-install.sh`, `yazi-install.sh`, `ghostty-install.sh`, `_helpers.sh`, `fastfetch-install.sh`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `$schema`, `plugin`, `_options.sh script` to the rest of the system?**
  _136 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `cecho` be split into smaller, more focused modules?**
  _Cohesion score 0.11265969802555169 - nodes in this community are weakly interconnected._
- **Should `Hermes Agent` be split into smaller, more focused modules?**
  _Cohesion score 0.07881773399014778 - nodes in this community are weakly interconnected._
- **Should `homebrew-install.sh` be split into smaller, more focused modules?**
  _Cohesion score 0.0784313725490196 - nodes in this community are weakly interconnected._