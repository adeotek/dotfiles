# Graph Report - .dotfiles  (2026-10-10)

## Corpus Check
- 168 files · ~68,964 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 42 file(s) not represented in the graph (top: (none) 7, .toml 7, .service 6)

## Summary
- 585 nodes · 1070 edges · 73 communities (37 shown, 36 thin omitted)
- Extraction: 83% EXTRACTED · 17% INFERRED · 0% AMBIGUOUS · INFERRED: 182 edges (avg confidence: 0.61)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `103dd3c1`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- uv-install.sh
- install_package
- Dotfiles README
- starship-install.sh
- statusline-command.sh
- _options.sh
- merge-opencode-config.py
- pi-lens-config.json
- AGENTS.md — Operational Rules for AI Agents
- bash
- claude-code-setup.sh
- AdeoTEK Scripting Best Practices (Strictly Enforced)
- config.bash
- wsl-setup-fedora-dev.sh
- cc-sessions.sh
- k8s-repo-install.sh
- pi-install.sh
- dotnet-unit-testing Skill (opencode)
- Run-LocalWinEnvSetup.ps1
- headroom-uninstall.sh
- setup.sh
- Get-GitHubStats.ps1
- Windows Network/Firewall Diagnostic Tools
- expert.md
- tutor.md
- cache-clean.sh
- _helpers.sh
- hermes-update-daily.sh
- devops.md
- .NET Backend Expert Agent (opencode)
- opencode.json
- start-opencode-server.sh
- Run-CacheClean.ps1
- unattended_setup.sh
- ai-config.bash
- hermes-update-notify.sh
- gbs Oh My Posh theme
- update.sh
- Homebrew Fallback Package Manager
- dev.md
- Tabby terminal config
- zsh_plugins.txt — External ZSH Plugin Manifest
- decho
- cli.json
- kitty-install.sh
- cecho
- fastfetch-install.sh
- nodejs-install.sh
- ai-tools-update.sh
- herdr-setup.sh
- init-agents.md
- tmux-install.sh

## God Nodes (most connected - your core abstractions)
1. `cecho()` - 71 edges
2. `install_package()` - 31 edges
3. `decho()` - 22 edges
4. `stow_package()` - 22 edges
5. `cache-clean.sh script` - 20 edges
6. `section()` - 20 edges
7. `Remove-CachePath()` - 20 edges
8. `vlog()` - 16 edges
9. `Write-Section()` - 16 edges
10. `cecho()` - 15 edges

## Surprising Connections (you probably didn't know these)
- `.NET Unit Test Expert Agent (opencode)` --semantically_similar_to--> `.NET Unit Test Expert Subagent (pi)`  [INFERRED] [semantically similar]
  opencode/agents/dotnet-unit-test-expert.md → pi/agents/dotnet-unit-test-expert.md
- `dotnet-unit-testing Skill (opencode)` --semantically_similar_to--> `dotnet-unit-testing Skill (pi)`  [INFERRED] [semantically similar]
  opencode/skills/dotnet-unit-testing/SKILL.md → pi/skills/dotnet-unit-testing/SKILL.md
- `Zed config documentation` --references--> `Zed settings.json (stowed)`  [INFERRED]
  docs/zed.md → .zed/settings.json
- `Global Claude Code Instructions (LSP-first navigation, playwright-cli)` --semantically_similar_to--> `AGENTS.md (project agent guidelines)`  [INFERRED] [semantically similar]
  claude-code/user-config/CLAUDE.md → AGENTS.md
- `Rename-Files.ps1 (Bulk Rename with Dry-Run)` --semantically_similar_to--> `Dry-Run Safety Pattern`  [INFERRED] [semantically similar]
  win-tools/.tools/Rename-Files.ps1 → _scripts/core/_helpers.sh

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Multi-distro GNU Stow deployment flow** — readme_gnu_stow, readme_package_tiers, agents, _opencode_agents_dotfiles_scripting_conventions [EXTRACTED 0.90]
- **Hermes multi-agent persona and agent-to-agent messaging protocol** — hermes__hermes_soul, hermes__hermes_profiles_foca_soul, hermes_config, hermes__hermes_profiles_foca_config [EXTRACTED 0.95]
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
- **AI agent tooling and proxy stack** — docs_headroom_headroom, docs_hermes_hermes_agent, docs_paseo_paseo_daemon, _opencode_opencode, docs_zed_acp_agent_integration [INFERRED 0.85]
- **AI Coding Tools** — scripts_core_claude_code_install, scripts_core_claude_code_setup, scripts_core_opencode_install, scripts_core_opencode_setup [INFERRED 0.85]
- **dotnet-unit-testing Skill Chain (xUnit/NSubstitute tooling)** — opencode_skills_dotnet_unit_testing_skill, pi_skills_dotnet_unit_testing_skill, opencode_agents_dotnet_unit_test_expert, pi_agents_dotnet_unit_test_expert, opencode_skills_dotnet_unit_testing_skill_arrange_act_assert, opencode_skills_dotnet_unit_testing_skill_nsubstitute_mocking [INFERRED 0.85]
- **Pi Agent Set Ported from OpenCode Definitions** — pi_agents_code_review, pi_agents_devops, pi_agents_dotnet_backend_expert, pi_agents_dotnet_unit_test_expert, pi_agents_expert, pi_agents_tutor, opencode_agents_code_review, opencode_agents_devops, opencode_agents_dotnet_backend_expert, opencode_agents_dotnet_unit_test_expert, opencode_agents_expert, opencode_agents_tutor [INFERRED 0.85]
- **Pi Agent System Prompt Assembly (global rules + appended system)** — pi_agents, pi_append_system, pi_agents_code_review, pi_agents_expert [INFERRED 0.85]
- **Setup-Wraps-Install Pattern** — scripts_core_fastfetch_setup, scripts_core_fastfetch_install, scripts_core_git_setup, scripts_core_git_install, scripts_core_jetbrains_toolbox_setup, scripts_core_jetbrains_toolbox_install [INFERRED 0.85]
- **Shell Prompt Tools with Nerd Fonts** — scripts_core_starship_install, scripts_core_oh_my_posh_install, scripts_core_nerd_fonts_install [INFERRED 0.85]
- **Cross-Platform Claude Code Session Browsers** — tools_tools_cc_sessions, win_tools_get_cc_sessions [INFERRED 0.95]
- **Kubernetes Toolchain** — scripts_core_k8s_repo_install, scripts_core_kubectl_install, scripts_core_helm_install [INFERRED 0.95]
- **Claude Code Statusline Variants** — claude_code_user_config_statusline_command, claude_code_user_config_statusline_command_win, claude_code_user_config_statusline_slim [INFERRED 0.95]
- **Windows Network & Firewall Tools** — win_tools_tools_add_winfirewallrule, win_tools_tools_get_winfirewallrulebyport, win_tools_run_port_listen, win_tools_run_port_probe [INFERRED 0.95]

## Communities (73 total, 36 thin omitted)

### Community 0 - "uv-install.sh"
Cohesion: 0.20
Nodes (5): ansible-cleanup.sh script, ansible-install.sh script, graphify-install.sh script, headroom-install.sh script, uv-install.sh script

### Community 1 - "install_package"
Cohesion: 0.11
Nodes (13): base-tools-install.sh script, glow-install.sh script, install_package(), HOMEBREW_NO_ASK, homebrew-install.sh script, lsp-servers-install.sh script, onefetch-install.sh script, rtk-install.sh script (+5 more)

### Community 2 - "Dotfiles README"
Cohesion: 0.07
Nodes (26): Dotfiles Agent (OpenCode subagent definition), Graphify knowledge-graph tool, OpenCode global config (opencode.json), Graphify OpenCode plugin (.opencode/plugins/graphify.js), Zed settings.json (stowed), AGENTS.md (project agent guidelines), Global Claude Code Instructions (LSP-first navigation, playwright-cli), Headroom documentation (+18 more)

### Community 3 - "starship-install.sh"
Cohesion: 0.17
Nodes (10): Shell Prompt Customization Tool, bash-setup.sh script, process_args(), _helpers.sh script, nerd-fonts-install.sh script, oh-my-posh-install.sh script, oh-my-posh-setup.sh script, starship-install.sh script (+2 more)

### Community 4 - "statusline-command.sh"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 5 - "_options.sh"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 6 - "merge-opencode-config.py"
Cohesion: 0.19
Nodes (8): _key(), main(), merge(), strip_jsonc(), _key(), main(), merge(), strip_jsonc()

### Community 7 - "pi-lens-config.json"
Cohesion: 0.11
Nodes (17): autofix, enabled, contextInjection, enabled, format, enabled, mode, ignore (+9 more)

### Community 8 - "AGENTS.md — Operational Rules for AI Agents"
Cohesion: 0.18
Nodes (9): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents (+1 more)

### Community 9 - "bash"
Cohesion: 0.14
Nodes (13): git commit *, git push *, rm *, sudo *, /tmp/*, *.env, *.env.example, next-env.d.ts (+5 more)

### Community 10 - "claude-code-setup.sh"
Cohesion: 0.20
Nodes (8): AI Coding Tools (claude-code + opencode), Claude Code Plugin Marketplace, claude-code-install.sh script, CLAUDECODE_MARKETPLACES, CLAUDECODE_PLUGINS, claude-code-setup.sh script, opencode-install.sh script, Run-LocalWinEnvSetup.ps1 (Windows Dev Setup)

### Community 11 - "AdeoTEK Scripting Best Practices (Strictly Enforced)"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 12 - "config.bash"
Cohesion: 0.24
Nodes (7): config.bash script, COLORTERM, EDITOR, LC_ALL, path_append(), path_prepend(), Shell PATH Setup (Homebrew/Rust/Go/dotnet)

### Community 13 - "wsl-setup-fedora-dev.sh"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 15 - "cc-sessions.sh"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 17 - "k8s-repo-install.sh"
Cohesion: 0.40
Nodes (3): Kubernetes Toolchain (kubectl + helm + k8s-repo), k8s-repo-install.sh script, kubectl-install.sh script

### Community 18 - "pi-install.sh"
Cohesion: 0.43
Nodes (5): pi_node_ok(), pi-install.sh script, copy_agents_if_missing(), copy_skills_if_missing(), pi-setup.sh script

### Community 19 - "dotnet-unit-testing Skill (opencode)"
Cohesion: 0.67
Nodes (6): .NET Unit Test Expert Agent (opencode), dotnet-unit-testing Skill (opencode), Arrange-Act-Assert (AAA) Test Pattern, NSubstitute Interface Mocking (Substitute.For, Arg matchers), .NET Unit Test Expert Subagent (pi), dotnet-unit-testing Skill (pi)

### Community 20 - "Run-LocalWinEnvSetup.ps1"
Cohesion: 0.60
Nodes (4): CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 21 - "headroom-uninstall.sh"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 22 - "setup.sh"
Cohesion: 0.60
Nodes (5): _render_grid(), _render_menu(), select_packages_grid(), setup.sh script, show_usage()

### Community 24 - "Windows Network/Firewall Diagnostic Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 25 - "expert.md"
Cohesion: 0.50
Nodes (3): Core Principles, Code Review Subagent (pi), Build/Orchestrator Subagent (pi)

### Community 26 - "tutor.md"
Cohesion: 0.40
Nodes (4): Core Principles, Response Style, When to Make Changes, Guided Learning Tutor Subagent (pi)

### Community 27 - "cache-clean.sh"
Cohesion: 0.22
Nodes (38): cecho(), dir_size_kb(), have(), human_lines_to_kb(), in_use(), measure(), path_in_use(), prune_old_entries() (+30 more)

### Community 28 - "_helpers.sh"
Cohesion: 0.11
Nodes (21): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, docker-install.sh script, headroom-setup.sh script, copy_files_if_missing() (+13 more)

### Community 33 - ".NET Backend Expert Agent (opencode)"
Cohesion: 1.00
Nodes (3): .NET Backend Expert Agent (opencode), Minimal API Pattern over MVC Controllers, .NET Backend Expert Subagent (pi)

### Community 35 - "start-opencode-server.sh"
Cohesion: 0.33
Nodes (6): CORS, FORWARD, OPT_CORS, serve_args, start-opencode-server.sh script, usage()

### Community 36 - "Run-CacheClean.ps1"
Cohesion: 0.24
Nodes (29): Format-KB(), Get-SizeKB(), Invoke-StepResult(), Invoke-ToolClean(), Measure-Paths(), Remove-CachePath(), Remove-OldEntries(), Remove-VsCodeServerStale() (+21 more)

### Community 62 - "decho"
Cohesion: 0.10
Nodes (17): aws-cli-install.sh script, ghostty-install.sh script, ghostty-setup.sh script, helm-install.sh script, decho(), execute_command(), rename_dir_if_exists(), rename_file_if_exists() (+9 more)

### Community 63 - "cli.json"
Cohesion: 0.17
Nodes (11): animations, diffs, wrap, $schema, session, scrollbar, sidebar, thinking (+3 more)

### Community 64 - "kitty-install.sh"
Cohesion: 0.24
Nodes (6): Install-Then-Setup Pattern, Terminal Emulator, kitty-install.sh script, kitty-setup.sh script, tabby-install.sh script, tabby-setup.sh script

### Community 65 - "cecho"
Cohesion: 0.09
Nodes (16): dotnet-install.sh script, gcp-cli-install.sh script, git-install.sh script, git-setup.sh script, github-cli-install.sh script, golang-install.sh script, aecho(), cecho() (+8 more)

### Community 67 - "nodejs-install.sh"
Cohesion: 0.25
Nodes (4): nodejs-install.sh script, nvim-install.sh script, nvim-setup.sh script, playwright-install.sh script

### Community 68 - "ai-tools-update.sh"
Cohesion: 0.70
Nodes (4): has(), run(), section(), ai-tools-update.sh script

### Community 69 - "herdr-setup.sh"
Cohesion: 0.50
Nodes (3): herdr-install.sh script, setup_herdr_completions(), herdr-setup.sh script

### Community 70 - "init-agents.md"
Cohesion: 0.50
Nodes (3): Pitfalls, Procedure, Verification (do before reporting done)

## Knowledge Gaps
- **54 isolated node(s):** `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS`, `CONSOLE_TASKS`, `CONSOLE_EXTRA_TASKS`, `ALL_CONSOLE_TASKS` (+49 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 171 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **36 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `cecho()` connect `cecho` to `uv-install.sh`, `install_package`, `fastfetch-install.sh`, `starship-install.sh`, `kitty-install.sh`, `herdr-setup.sh`, `nodejs-install.sh`, `tmux-install.sh`, `claude-code-setup.sh`, `k8s-repo-install.sh`, `pi-install.sh`, `_helpers.sh`, `decho`?**
  _High betweenness centrality (0.038) - this node is a cross-community bridge._
- **What connects `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS`, `CONSOLE_TASKS` to the rest of the system?**
  _54 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `install_package` be split into smaller, more focused modules?**
  _Cohesion score 0.10666666666666667 - nodes in this community are weakly interconnected._
- **Why does `install_package()` connect `install_package` to `kitty-install.sh`, `cecho`, `fastfetch-install.sh`, `starship-install.sh`, `nodejs-install.sh`, `tmux-install.sh`, `k8s-repo-install.sh`, `_helpers.sh`, `decho`?**
  _High betweenness centrality (0.011) - this node is a cross-community bridge._
- **Should `Dotfiles README` be split into smaller, more focused modules?**
  _Cohesion score 0.0748663101604278 - nodes in this community are weakly interconnected._
- **Why does `stow_package()` connect `decho` to `kitty-install.sh`, `cecho`, `fastfetch-install.sh`, `starship-install.sh`, `install_package`, `nodejs-install.sh`, `tmux-install.sh`, `_helpers.sh`?**
  _High betweenness centrality (0.010) - this node is a cross-community bridge._
- **Should `_options.sh` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._