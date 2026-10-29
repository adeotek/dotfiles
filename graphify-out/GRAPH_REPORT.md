# Graph Report - .dotfiles  (2026-10-28)

## Corpus Check
- 183 files · ~76,233 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 43 file(s) not represented in the graph (top: (none) 8, .toml 7, .service 6)

## Summary
- 1882 nodes · 2387 edges · 177 communities (140 shown, 37 thin omitted)
- Extraction: 92% EXTRACTED · 8% INFERRED · 0% AMBIGUOUS · INFERRED: 184 edges (avg confidence: 0.6)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `25a434b4`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- cecho
- homebrew-install.sh
- starship-install.sh
- stow_package
- .NET Unit Test Expert Agent
- claude-code-setup.sh
- statusline-command.sh
- _helpers.sh
- _options.sh
- AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles
- claude-code-setup.sh
- AdeoTEK Scripting Best Practices (Strictly Enforced)
- Hermes Agent
- microsoft-repo-install.sh
- cc-sessions.sh
- hotkeys
- install_package
- k8s-repo-install.sh
- expert build/orchestrator agent
- headroom-uninstall.sh
- Get-GitHubStats.ps1
- Run-LocalWinEnvSetup.ps1
- Windows Network/Firewall Diagnostic Tools
- dotnet-unit-test-expert agent
- opencode/agents/tutor.md
- config.bash
- cecho
- Dry-Run Safety Pattern
- opencode.json
- graphify.js
- AGENTS.md — working rules
- tui.json
- homebrew-install.sh
- read_yes_no
- unattended_setup.sh
- workflows/graphify.md
- hermes-update-notify.sh
- AGENTS.md — Operational Rules for AI Agents
- opencode/agents/devops.md
- Homebrew Fallback Package Manager
- Zed — stowed config + setup notes
- microsoft-repo-install.sh
- install_package
- Paseo daemon (dotfiles template)
- kitty-install.sh
- microsoft-repo-install.sh
- _helpers.sh
- display
- catppuccin
- symlink_package_file
- pi/agents/code-review.md
- github-cli-install.sh
- display
- Run-AIToolsUpdate.ps1
- debug.md
- document-code.md
- wsl-setup-fedora-dev.sh
- properties
- fastfetch-install.sh
- tts
- github-cli-install.sh
- tts
- agent
- agent
- tabby/config.yaml
- properties
- palette
- hermes/config.yaml
- foca/config.yaml
- terminal
- terminal
- discord
- discord
- browser
- browser
- delegation
- delegation
- palette
- dashboard
- security
- dashboard
- security
- curator
- guardrail
- tool_loop_guardrails
- kanban
- curator
- guardrail
- tool_loop_guardrails
- kanban
- gbs.omp.yaml
- yazi-install.sh
- checkpoints
- compression
- memory
- checkpoints
- compression
- memory
- skills
- skills
- segments
- auxiliary
- vision
- voice
- auxiliary
- vision
- voice
- approvals
- compression
- curator
- kanban_decomposer
- mcp
- monitor
- profile_describer
- skills_hub
- title_generation
- triage_specifier
- tts_audio_tags
- web_extract
- approvals
- compression
- curator
- kanban_decomposer
- mcp
- monitor
- profile_describer
- skills_hub
- title_generation
- triage_specifier
- tts_audio_tags
- web_extract
- tool_search
- telegram
- fallback_providers
- model
- web
- telegram
- fallback_providers
- model
- web
- code_execution
- human_delay
- matrix
- mattermost
- openrouter
- slack
- tool_search
- code_execution
- matrix
- mattermost
- openrouter
- slack
- tool_output
- plugins
- mapped_shell_names

## God Nodes (most connected - your core abstractions)
1. `hotkeys` - 100 edges
2. `cecho()` - 75 edges
3. `properties` - 44 edges
4. `display` - 40 edges
5. `display` - 40 edges
6. `properties` - 34 edges
7. `install_package()` - 31 edges
8. `terminal` - 25 edges
9. `terminal` - 25 edges
10. `decho()` - 22 edges

## Surprising Connections (you probably didn't know these)
- `.NET Unit Test Expert Agent (opencode)` --semantically_similar_to--> `.NET Unit Test Expert Subagent (pi)`  [INFERRED] [semantically similar]
  opencode/agents/dotnet-unit-test-expert.md → pi/agents/dotnet-unit-test-expert.md
- `dotnet-unit-testing Skill (opencode)` --semantically_similar_to--> `dotnet-unit-testing Skill (pi)`  [INFERRED] [semantically similar]
  opencode/skills/dotnet-unit-testing/SKILL.md → pi/skills/dotnet-unit-testing/SKILL.md
- `Zed config documentation` --references--> `Zed settings.json (stowed)`  [INFERRED]
  docs/zed.md → .zed/settings.json
- `Global Claude Code Instructions (LSP-first navigation, playwright-cli)` --semantically_similar_to--> `AGENTS.md (project agent guidelines)`  [INFERRED] [semantically similar]
  claude-code/user-config/CLAUDE.md → AGENTS.md
- `.NET Backend Expert Agent (opencode)` --semantically_similar_to--> `.NET Backend Expert Subagent (pi)`  [INFERRED] [semantically similar]
  opencode/agents/dotnet-backend-expert.md → pi/agents/dotnet-backend-expert.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Multi-distro GNU Stow deployment flow** — readme_gnu_stow, readme_package_tiers, agents, _opencode_agents_dotfiles_scripting_conventions [EXTRACTED 0.90]
- **Hermes multi-agent persona and agent-to-agent messaging protocol** — hermes__hermes_soul, hermes__hermes_profiles_foca_soul, hermes_config, hermes__hermes_profiles_foca_config [EXTRACTED 0.95]
- **Entry Points Using Shared Core** — dotfiles_setup, dotfiles_unattended_setup, dotfiles_update, scripts_core_helpers, scripts_core_options [EXTRACTED 1.00]
- **_helpers.sh as Universal Hub** — scripts_core_helpers, scripts_core_options, scripts_core_zed_setup, scripts_core_ghostty_setup, scripts_core_tmux_setup, scripts_core_claude_code_setup [EXTRACTED 1.00]
- **Terminal Emulator Tools** — scripts_core_kitty_install, scripts_core_tabby_install, scripts_core_zed_install [INFERRED 0.65]
- **Tools Using Homebrew as Fallback** — scripts_core_starship_install, scripts_core_nvim_install, scripts_core_onefetch_install, scripts_core_yazi_install, scripts_core_homebrew_install [INFERRED 0.75]
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

## Communities (177 total, 37 thin omitted)

### Community 0 - "cecho"
Cohesion: 0.40
Nodes (3): zed-install.sh script, zed-setup.sh script, Zed Editor settings.json

### Community 1 - "homebrew-install.sh"
Cohesion: 0.14
Nodes (8): base-tools-install.sh script, glow-install.sh script, HOMEBREW_NO_ASK, homebrew-install.sh script, onefetch-install.sh script, rtk-install.sh script, rtk-setup.sh script, zsh-install.sh script

### Community 2 - "starship-install.sh"
Cohesion: 0.09
Nodes (20): Dotfiles Agent (OpenCode subagent definition), Graphify knowledge-graph tool, Zed settings.json (stowed), AGENTS.md (project agent guidelines), Global Claude Code Instructions (LSP-first navigation, playwright-cli), Headroom documentation, Headroom (LLM context compression proxy), Hermes Agent documentation (+12 more)

### Community 3 - "stow_package"
Cohesion: 0.09
Nodes (14): Install-Then-Setup Pattern, Shell Prompt Customization Tool, Terminal Emulator, bash-setup.sh script, ghostty-setup.sh script, kitty-setup.sh script, nvim-setup.sh script, oh-my-posh-install.sh script (+6 more)

### Community 4 - ".NET Unit Test Expert Agent"
Cohesion: 0.17
Nodes (17): settings-part.json (Claude Code Settings), fmt_ctx_size(), fmt_pct(), fmt_reset_time(), get_mtime(), pct_color(), statusline-command.sh script, cents_to_dollars() (+9 more)

### Community 5 - "claude-code-setup.sh"
Cohesion: 0.11
Nodes (18): Task Tier Hierarchy (Minimal/Console/Desktop), setup.sh (Interactive Setup), unattended_setup.sh (Unattended Setup), update.sh (System Update), ALL_CONSOLE_TASKS, ALL_DESKTOP_TASKS, ALL_TASKS, CONSOLE_EXTRA_TASKS (+10 more)

### Community 6 - "statusline-command.sh"
Cohesion: 0.15
Nodes (12): _key(), main(), merge(), strip_jsonc(), _key(), main(), merge(), strip_jsonc() (+4 more)

### Community 7 - "_helpers.sh"
Cohesion: 0.11
Nodes (17): autofix, enabled, contextInjection, enabled, format, enabled, mode, ignore (+9 more)

### Community 8 - "_options.sh"
Cohesion: 0.18
Nodes (9): 1. Git Commit Policy — ALWAYS FOLLOW, 2. Verification Before Done, 3. Analysis/Plan Phase, 4. Lazy-Loading Sub-Rules, 5. General Conduct, 6. Code Intelligence and Navigation, 7. Browser Automation, AGENTS.md — Operational Rules for AI Agents (+1 more)

### Community 9 - "AGENTS.md — Agent Coding Guidelines for AdeoTEK Dotfiles"
Cohesion: 0.14
Nodes (13): git commit *, git push *, rm *, sudo *, /tmp/*, *.env, *.env.example, next-env.d.ts (+5 more)

### Community 10 - "claude-code-setup.sh"
Cohesion: 0.13
Nodes (11): AI Coding Tools (claude-code + opencode), Claude Code Plugin Marketplace, claude-code-install.sh script, CLAUDECODE_MARKETPLACES, CLAUDECODE_PLUGINS, claude-code-setup.sh script, opencode-install.sh script, pi_node_ok() (+3 more)

### Community 11 - "AdeoTEK Scripting Best Practices (Strictly Enforced)"
Cohesion: 0.18
Nodes (10): 1. Robust Conditional Logic, 2. Error Handling & Indentation, 3. Function & Variable Scoping, 4. Output & Logging Helpers, 5. Side-Effect Guarding (Dry Runs), 6. Script Setup Pattern, AdeoTEK Scripting Best Practices (Strictly Enforced), Core Responsibilities (+2 more)

### Community 12 - "Hermes Agent"
Cohesion: 0.24
Nodes (7): config.bash script, COLORTERM, EDITOR, LC_ALL, path_append(), path_prepend(), Shell PATH Setup (Homebrew/Rust/Go/dotnet)

### Community 13 - "microsoft-repo-install.sh"
Cohesion: 0.25
Nodes (4): dotnet-install.sh script, microsoft-repo-install.sh script, powershell-install.sh script, vscode-install.sh script

### Community 15 - "cc-sessions.sh"
Cohesion: 0.29
Nodes (7): Claude Code Session Browser (cross-platform), ordered_projects, rm_files, rm_labels, seen_projects, cc-sessions.sh script, Get-ClaudeCodeSessions.ps1 (Win Session Browser)

### Community 17 - "hotkeys"
Cohesion: 0.02
Nodes (100): hotkeys, clear, close-pane, close-tab, combine-tabs, command-selector, copy, copy-current-path (+92 more)

### Community 18 - "install_package"
Cohesion: 0.14
Nodes (22): gcp-cli-install.sh script, ghostty-install.sh script, git-install.sh script, git-setup.sh script, decho(), execute_command(), install_package(), process_args() (+14 more)

### Community 19 - "k8s-repo-install.sh"
Cohesion: 0.67
Nodes (6): .NET Unit Test Expert Agent (opencode), dotnet-unit-testing Skill (opencode), Arrange-Act-Assert (AAA) Test Pattern, NSubstitute Interface Mocking (Substitute.For, Arg matchers), .NET Unit Test Expert Subagent (pi), dotnet-unit-testing Skill (pi)

### Community 20 - "expert build/orchestrator agent"
Cohesion: 0.60
Nodes (4): CreateAlias(), ExitWithMessage(), ReadConfigFile(), Write-Color()

### Community 21 - "headroom-uninstall.sh"
Cohesion: 0.60
Nodes (5): confirm_or_exit(), remove_path(), headroom-uninstall.sh script, systemd_user_available(), usage()

### Community 22 - "Get-GitHubStats.ps1"
Cohesion: 0.60
Nodes (5): _render_grid(), _render_menu(), select_packages_grid(), setup.sh script, show_usage()

### Community 24 - "Windows Network/Firewall Diagnostic Tools"
Cohesion: 0.60
Nodes (3): Windows Network/Firewall Diagnostic Tools, Run-PortListen.ps1 (TCP/UDP Listener), Run-PortProbe.ps1 (TCP Connectivity Test)

### Community 25 - "dotnet-unit-test-expert agent"
Cohesion: 0.50
Nodes (3): Core Principles, Code Review Subagent (pi), Build/Orchestrator Subagent (pi)

### Community 26 - "opencode/agents/tutor.md"
Cohesion: 0.40
Nodes (4): Core Principles, Response Style, When to Make Changes, Guided Learning Tutor Subagent (pi)

### Community 27 - "config.bash"
Cohesion: 0.22
Nodes (38): cecho(), dir_size_kb(), have(), human_lines_to_kb(), in_use(), measure(), path_in_use(), prune_old_entries() (+30 more)

### Community 28 - "cecho"
Cohesion: 0.17
Nodes (20): ansible-install.sh script, docker-install.sh script, headroom-setup.sh script, cecho(), copy_files_if_missing(), enable_lingering(), enable_wsl_systemd(), read_yes_no() (+12 more)

### Community 33 - "graphify.js"
Cohesion: 1.00
Nodes (3): .NET Backend Expert Agent (opencode), Minimal API Pattern over MVC Controllers, .NET Backend Expert Subagent (pi)

### Community 34 - "AGENTS.md — working rules"
Cohesion: 0.22
Nodes (8): AGENTS.md — working rules, Approval required, Before changing code, Commit and PR titles, Project context and skills, Scope, Tools, Verification

### Community 35 - "tui.json"
Cohesion: 0.33
Nodes (6): CORS, FORWARD, OPT_CORS, serve_args, start-opencode-server.sh script, usage()

### Community 36 - "homebrew-install.sh"
Cohesion: 0.24
Nodes (29): Format-KB(), Get-SizeKB(), Invoke-StepResult(), Invoke-ToolClean(), Measure-Paths(), Remove-CachePath(), Remove-OldEntries(), Remove-VsCodeServerStale() (+21 more)

### Community 62 - "install_package"
Cohesion: 0.33
Nodes (4): Kubernetes Toolchain (kubectl + helm + k8s-repo), helm-install.sh script, k8s-repo-install.sh script, kubectl-install.sh script

### Community 63 - "Paseo daemon (dotfiles template)"
Cohesion: 0.17
Nodes (11): animations, diffs, wrap, $schema, session, scrollbar, sidebar, thinking (+3 more)

### Community 64 - "kitty-install.sh"
Cohesion: 0.20
Nodes (9): Default configuration, Install, moca (MO Coding Agent) — dotfiles setup, Ollama (local or LAN), Paseo (ACP), Providers and credentials, Slash commands (prompt templates), Update (+1 more)

### Community 65 - "microsoft-repo-install.sh"
Cohesion: 0.40
Nodes (4): 📝 Code Template, 🛠 Core Methodology, .NET Unit Test Expert Skill, 📂 Project Integration

### Community 66 - "_helpers.sh"
Cohesion: 0.06
Nodes (21): Dry-Run Safety Pattern, Dry-Run Pattern in PowerShell Tools, Multi-Distro Support (Arch/Debian/Fedora), OS-Dispatch Pattern (case $CURRENT_OS_ID), stow_package() Helper Function, ansible-cleanup.sh script, aws-cli-install.sh script, golang-install.sh script (+13 more)

### Community 67 - "display"
Cohesion: 0.04
Nodes (48): streaming, display, background_process_notifications, bell_on_complete, busy_input_mode, cleanup_progress, compact, copy_shortcut (+40 more)

### Community 68 - "catppuccin"
Cohesion: 0.70
Nodes (4): has(), run(), section(), ai-tools-update.sh script

### Community 69 - "symlink_package_file"
Cohesion: 0.50
Nodes (3): herdr-install.sh script, setup_herdr_completions(), herdr-setup.sh script

### Community 70 - "pi/agents/code-review.md"
Cohesion: 0.50
Nodes (3): Pitfalls, Procedure, Verification (do before reporting done)

### Community 71 - "github-cli-install.sh"
Cohesion: 0.50
Nodes (3): Gather the change, Report, What to look for, in this order

### Community 72 - "display"
Cohesion: 0.04
Nodes (48): streaming, display, background_process_notifications, bell_on_complete, busy_input_mode, cleanup_progress, compact, copy_shortcut (+40 more)

### Community 73 - "Run-AIToolsUpdate.ps1"
Cohesion: 0.33
Nodes (5): Get-LatestRtkRelease(), Get-RtkExePath(), Get-RtkVersion(), Invoke-RtkFromSourceUpdate(), Test-RtkRunning()

### Community 74 - "debug.md"
Cohesion: 0.50
Nodes (3): Fix and verify, Locate the cause, Reproduce first

### Community 75 - "document-code.md"
Cohesion: 0.50
Nodes (3): Recon, Verify before reporting done, Write

### Community 77 - "wsl-setup-fedora-dev.sh"
Cohesion: 0.33
Nodes (8): WSL2 Environment Support, DOTFILES_PACKAGES, echo_error(), echo_warning(), wsl-setup-fedora-dev.sh script, stage_status(), usage(), _vscode_candidates

### Community 78 - "properties"
Cohesion: 0.04
Nodes (45): pwsh, alpine, always_enabled, arch, branch_ahead_icon, branch_behind_icon, branch_gone_icon, branch_icon (+37 more)

### Community 80 - "tts"
Cohesion: 0.05
Nodes (43): voice, diarize, language_code, model_id, tag_audio_events, voice_id, audio_tags, model (+35 more)

### Community 82 - "tts"
Cohesion: 0.05
Nodes (43): voice, diarize, language_code, model_id, tag_audio_events, voice_id, audio_tags, model (+35 more)

### Community 83 - "agent"
Cohesion: 0.05
Nodes (41): agent, api_max_retries, clarify_timeout, coding_context, disabled_toolsets, environment_hint, environment_probe, gateway_auto_continue_freshness (+33 more)

### Community 84 - "agent"
Cohesion: 0.05
Nodes (41): agent, api_max_retries, clarify_timeout, coding_context, disabled_toolsets, environment_hint, environment_probe, gateway_auto_continue_freshness (+33 more)

### Community 85 - "tabby/config.yaml"
Cohesion: 0.06
Nodes (33): accessibility, appearance, opacity, clickableLinks, background, colors, cursor, foreground (+25 more)

### Community 86 - "properties"
Cohesion: 0.06
Nodes (33): alpine, always_enabled, arch, branch_max_length, cache_duration, debian, display_mode, elementary (+25 more)

### Community 87 - "palette"
Cohesion: 0.06
Nodes (30): blocks, alignment, newline, segments, type, final_space, palette, bg (+22 more)

### Community 88 - "hermes/config.yaml"
Cohesion: 0.09
Nodes (23): Foca profile Hermes config (config.yaml), Foca persona SOUL.md (foca profile), Mo persona SOUL.md (Hermes default profile), command_allowlist, context, engine, cron, wrap_response (+15 more)

### Community 89 - "foca/config.yaml"
Cohesion: 0.08
Nodes (25): command_allowlist, context, engine, cron, wrap_response, file_read_max_chars, goals, max_turns (+17 more)

### Community 90 - "terminal"
Cohesion: 0.08
Nodes (25): terminal, auto_source_bashrc, backend, container_cpu, container_disk, container_memory, container_persistent, cwd (+17 more)

### Community 91 - "terminal"
Cohesion: 0.08
Nodes (25): terminal, auto_source_bashrc, backend, container_cpu, container_disk, container_memory, container_persistent, cwd (+17 more)

### Community 92 - "discord"
Cohesion: 0.09
Nodes (22): discord, allow_any_attachment, allowed_channels, auto_thread, dm_role_auth_guild, free_response_channels, history_backfill, history_backfill_limit (+14 more)

### Community 93 - "discord"
Cohesion: 0.09
Nodes (22): discord, allow_any_attachment, allowed_channels, auto_thread, dm_role_auth_guild, free_response_channels, history_backfill, history_backfill_limit (+14 more)

### Community 94 - "browser"
Cohesion: 0.11
Nodes (19): browser, allow_private_urls, auto_local_for_private_urls, camofox, cdp_url, cloud_provider, command_timeout, dialog_policy (+11 more)

### Community 95 - "browser"
Cohesion: 0.11
Nodes (19): browser, allow_private_urls, auto_local_for_private_urls, camofox, cdp_url, cloud_provider, command_timeout, dialog_policy (+11 more)

### Community 96 - "delegation"
Cohesion: 0.14
Nodes (14): delegation, api_key, api_mode, base_url, child_timeout_seconds, inherit_mcp_toolsets, max_concurrent_children, max_iterations (+6 more)

### Community 97 - "delegation"
Cohesion: 0.14
Nodes (14): delegation, api_key, api_mode, base_url, child_timeout_seconds, inherit_mcp_toolsets, max_concurrent_children, max_iterations (+6 more)

### Community 98 - "palette"
Cohesion: 0.14
Nodes (14): palette, bg, blue, dfg, fg, green, lavender, orange (+6 more)

### Community 99 - "dashboard"
Cohesion: 0.15
Nodes (13): password, password_hash, secret, session_ttl_seconds, username, dashboard, basic_auth, oauth (+5 more)

### Community 100 - "security"
Cohesion: 0.15
Nodes (13): security, acked_advisories, allow_lazy_installs, allow_private_urls, redact_secrets, tirith_enabled, tirith_fail_open, tirith_path (+5 more)

### Community 101 - "dashboard"
Cohesion: 0.15
Nodes (13): password, password_hash, secret, session_ttl_seconds, username, dashboard, basic_auth, oauth (+5 more)

### Community 102 - "security"
Cohesion: 0.15
Nodes (13): security, acked_advisories, allow_lazy_installs, allow_private_urls, redact_secrets, tirith_enabled, tirith_fail_open, tirith_path (+5 more)

### Community 103 - "curator"
Cohesion: 0.18
Nodes (11): enabled, keep, curator, archive_after_days, backup, consolidate, enabled, interval_hours (+3 more)

### Community 104 - "guardrail"
Cohesion: 0.18
Nodes (11): bedrock, discovery, guardrail, region, enabled, provider_filter, refresh_interval, guardrail_identifier (+3 more)

### Community 105 - "tool_loop_guardrails"
Cohesion: 0.18
Nodes (11): exact_failure, idempotent_no_progress, same_tool_failure, tool_loop_guardrails, hard_stop_after, hard_stop_enabled, warn_after, warnings_enabled (+3 more)

### Community 106 - "kanban"
Cohesion: 0.18
Nodes (11): kanban, auto_decompose, auto_decompose_per_tick, default_assignee, dispatch_in_gateway, dispatch_interval_seconds, dispatch_stale_timeout_seconds, failure_limit (+3 more)

### Community 107 - "curator"
Cohesion: 0.18
Nodes (11): enabled, keep, curator, archive_after_days, backup, consolidate, enabled, interval_hours (+3 more)

### Community 108 - "guardrail"
Cohesion: 0.18
Nodes (11): bedrock, discovery, guardrail, region, enabled, provider_filter, refresh_interval, guardrail_identifier (+3 more)

### Community 109 - "tool_loop_guardrails"
Cohesion: 0.18
Nodes (11): exact_failure, idempotent_no_progress, same_tool_failure, tool_loop_guardrails, hard_stop_after, hard_stop_enabled, warn_after, warnings_enabled (+3 more)

### Community 110 - "kanban"
Cohesion: 0.18
Nodes (11): kanban, auto_decompose, auto_decompose_per_tick, default_assignee, dispatch_in_gateway, dispatch_interval_seconds, dispatch_stale_timeout_seconds, failure_limit (+3 more)

### Community 111 - "gbs.omp.yaml"
Cohesion: 0.20
Nodes (9): blocks, alignment, newline, type, final_space, shell_integration, var, WinOS (+1 more)

### Community 112 - "yazi-install.sh"
Cohesion: 0.20
Nodes (5): increase_ulimit(), rustup-install.sh script, yazi-install.sh script, yazi-setup.sh script, zellij-install.sh script

### Community 113 - "checkpoints"
Cohesion: 0.22
Nodes (9): checkpoints, auto_prune, delete_orphans, enabled, max_file_size_mb, max_snapshots, max_total_size_mb, min_interval_hours (+1 more)

### Community 114 - "compression"
Cohesion: 0.22
Nodes (9): compression, abort_on_summary_failure, codex_gpt55_autoraise, enabled, hygiene_hard_message_limit, protect_first_n, protect_last_n, target_ratio (+1 more)

### Community 115 - "memory"
Cohesion: 0.22
Nodes (9): memory, flush_min_turns, memory_char_limit, memory_enabled, nudge_interval, provider, user_char_limit, user_profile_enabled (+1 more)

### Community 116 - "checkpoints"
Cohesion: 0.22
Nodes (9): checkpoints, auto_prune, delete_orphans, enabled, max_file_size_mb, max_snapshots, max_total_size_mb, min_interval_hours (+1 more)

### Community 117 - "compression"
Cohesion: 0.22
Nodes (9): compression, abort_on_summary_failure, codex_gpt55_autoraise, enabled, hygiene_hard_message_limit, protect_first_n, protect_last_n, target_ratio (+1 more)

### Community 118 - "memory"
Cohesion: 0.22
Nodes (9): memory, flush_min_turns, memory_char_limit, memory_enabled, nudge_interval, provider, user_char_limit, user_profile_enabled (+1 more)

### Community 119 - "skills"
Cohesion: 0.25
Nodes (8): skills, creation_nudge_interval, external_dirs, guard_agent_created, inline_shell, inline_shell_timeout, template_vars, write_approval

### Community 120 - "skills"
Cohesion: 0.25
Nodes (8): skills, creation_nudge_interval, external_dirs, guard_agent_created, inline_shell, inline_shell_timeout, template_vars, write_approval

### Community 121 - "segments"
Cohesion: 0.25
Nodes (8): segments, background, foreground, foreground_templates, style, template, trailing_diamond, type

### Community 122 - "auxiliary"
Cohesion: 0.29
Nodes (7): api_key, base_url, model, provider, timeout, auxiliary, approval

### Community 123 - "vision"
Cohesion: 0.29
Nodes (7): vision, api_key, base_url, download_timeout, model, provider, timeout

### Community 124 - "voice"
Cohesion: 0.29
Nodes (7): voice, auto_tts, beep_enabled, max_recording_seconds, record_key, silence_duration, silence_threshold

### Community 125 - "auxiliary"
Cohesion: 0.29
Nodes (7): api_key, base_url, model, provider, timeout, auxiliary, approval

### Community 126 - "vision"
Cohesion: 0.29
Nodes (7): vision, api_key, base_url, download_timeout, model, provider, timeout

### Community 127 - "voice"
Cohesion: 0.29
Nodes (7): voice, auto_tts, beep_enabled, max_recording_seconds, record_key, silence_duration, silence_threshold

### Community 128 - "approvals"
Cohesion: 0.33
Nodes (6): approvals, cron_mode, destructive_slash_confirm, mcp_reload_confirm, mode, timeout

### Community 129 - "compression"
Cohesion: 0.33
Nodes (6): compression, api_key, base_url, model, provider, timeout

### Community 130 - "curator"
Cohesion: 0.33
Nodes (6): curator, api_key, base_url, model, provider, timeout

### Community 131 - "kanban_decomposer"
Cohesion: 0.33
Nodes (6): kanban_decomposer, api_key, base_url, model, provider, timeout

### Community 132 - "mcp"
Cohesion: 0.33
Nodes (6): mcp, api_key, base_url, model, provider, timeout

### Community 133 - "monitor"
Cohesion: 0.33
Nodes (6): monitor, api_key, base_url, model, provider, timeout

### Community 134 - "profile_describer"
Cohesion: 0.33
Nodes (6): profile_describer, api_key, base_url, model, provider, timeout

### Community 135 - "skills_hub"
Cohesion: 0.33
Nodes (6): skills_hub, api_key, base_url, model, provider, timeout

### Community 136 - "title_generation"
Cohesion: 0.33
Nodes (6): title_generation, api_key, base_url, model, provider, timeout

### Community 137 - "triage_specifier"
Cohesion: 0.33
Nodes (6): triage_specifier, api_key, base_url, model, provider, timeout

### Community 138 - "tts_audio_tags"
Cohesion: 0.33
Nodes (6): tts_audio_tags, api_key, base_url, model, provider, timeout

### Community 139 - "web_extract"
Cohesion: 0.33
Nodes (6): web_extract, api_key, base_url, model, provider, timeout

### Community 140 - "approvals"
Cohesion: 0.33
Nodes (6): approvals, cron_mode, destructive_slash_confirm, mcp_reload_confirm, mode, timeout

### Community 141 - "compression"
Cohesion: 0.33
Nodes (6): compression, api_key, base_url, model, provider, timeout

### Community 142 - "curator"
Cohesion: 0.33
Nodes (6): curator, api_key, base_url, model, provider, timeout

### Community 143 - "kanban_decomposer"
Cohesion: 0.33
Nodes (6): kanban_decomposer, api_key, base_url, model, provider, timeout

### Community 144 - "mcp"
Cohesion: 0.33
Nodes (6): mcp, api_key, base_url, model, provider, timeout

### Community 145 - "monitor"
Cohesion: 0.33
Nodes (6): monitor, api_key, base_url, model, provider, timeout

### Community 146 - "profile_describer"
Cohesion: 0.33
Nodes (6): profile_describer, api_key, base_url, model, provider, timeout

### Community 147 - "skills_hub"
Cohesion: 0.33
Nodes (6): skills_hub, api_key, base_url, model, provider, timeout

### Community 148 - "title_generation"
Cohesion: 0.33
Nodes (6): title_generation, api_key, base_url, model, provider, timeout

### Community 149 - "triage_specifier"
Cohesion: 0.33
Nodes (6): triage_specifier, api_key, base_url, model, provider, timeout

### Community 150 - "tts_audio_tags"
Cohesion: 0.33
Nodes (6): tts_audio_tags, api_key, base_url, model, provider, timeout

### Community 151 - "web_extract"
Cohesion: 0.33
Nodes (6): web_extract, api_key, base_url, model, provider, timeout

### Community 152 - "tool_search"
Cohesion: 0.33
Nodes (6): enabled, max_search_limit, search_default_limit, threshold_pct, tools, tool_search

### Community 153 - "telegram"
Cohesion: 0.40
Nodes (5): rich_messages, telegram, allowed_chats, extra, reactions

### Community 154 - "fallback_providers"
Cohesion: 0.40
Nodes (5): fallback_providers, api_mode, base_url, model, provider

### Community 155 - "model"
Cohesion: 0.40
Nodes (5): model, api_mode, base_url, default, provider

### Community 156 - "web"
Cohesion: 0.40
Nodes (5): web, backend, extract_backend, search_backend, use_gateway

### Community 157 - "telegram"
Cohesion: 0.40
Nodes (5): rich_messages, telegram, allowed_chats, extra, reactions

### Community 158 - "fallback_providers"
Cohesion: 0.40
Nodes (5): fallback_providers, api_mode, base_url, model, provider

### Community 159 - "model"
Cohesion: 0.40
Nodes (5): model, api_mode, base_url, default, provider

### Community 160 - "web"
Cohesion: 0.40
Nodes (5): web, backend, extract_backend, search_backend, use_gateway

### Community 161 - "code_execution"
Cohesion: 0.50
Nodes (4): code_execution, max_tool_calls, mode, timeout

### Community 162 - "human_delay"
Cohesion: 0.50
Nodes (4): human_delay, max_ms, min_ms, mode

### Community 163 - "matrix"
Cohesion: 0.50
Nodes (4): matrix, allowed_rooms, free_response_rooms, require_mention

### Community 164 - "mattermost"
Cohesion: 0.50
Nodes (4): mattermost, allowed_channels, free_response_channels, require_mention

### Community 165 - "openrouter"
Cohesion: 0.50
Nodes (4): openrouter, min_coding_score, response_cache, response_cache_ttl

### Community 166 - "slack"
Cohesion: 0.50
Nodes (4): slack, allowed_channels, free_response_channels, require_mention

### Community 167 - "tool_search"
Cohesion: 0.50
Nodes (4): enabled, threshold_pct, tools, tool_search

### Community 168 - "code_execution"
Cohesion: 0.50
Nodes (4): code_execution, max_tool_calls, mode, timeout

### Community 169 - "matrix"
Cohesion: 0.50
Nodes (4): matrix, allowed_rooms, free_response_rooms, require_mention

### Community 170 - "mattermost"
Cohesion: 0.50
Nodes (4): mattermost, allowed_channels, free_response_channels, require_mention

### Community 171 - "openrouter"
Cohesion: 0.50
Nodes (4): openrouter, min_coding_score, response_cache, response_cache_ttl

### Community 172 - "slack"
Cohesion: 0.50
Nodes (4): slack, allowed_channels, free_response_channels, require_mention

### Community 173 - "tool_output"
Cohesion: 0.50
Nodes (4): tool_output, max_bytes, max_line_length, max_lines

### Community 174 - "plugins"
Cohesion: 0.67
Nodes (3): plugins, disabled, enabled

## Knowledge Gaps
- **55 isolated node(s):** `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS`, `CONSOLE_TASKS`, `CONSOLE_EXTRA_TASKS`, `ALL_CONSOLE_TASKS` (+50 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1252 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **37 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `auxiliary` connect `auxiliary` to `compression`, `curator`, `kanban_decomposer`, `mcp`, `monitor`, `profile_describer`, `skills_hub`, `title_generation`, `triage_specifier`, `tts_audio_tags`, `web_extract`, `foca/config.yaml`, `vision`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `MINIMAL_TASKS`, `CONSOLE_ONLY_TASKS`, `CONSOLE_TASKS` to the rest of the system?**
  _55 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `homebrew-install.sh` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
- **Why does `auxiliary` connect `auxiliary` to `compression`, `curator`, `kanban_decomposer`, `mcp`, `monitor`, `profile_describer`, `skills_hub`, `title_generation`, `triage_specifier`, `tts_audio_tags`, `web_extract`, `hermes/config.yaml`, `vision`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Should `starship-install.sh` be split into smaller, more focused modules?**
  _Cohesion score 0.08923076923076922 - nodes in this community are weakly interconnected._
- **Why does `agent` connect `agent` to `hermes/config.yaml`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `stow_package` be split into smaller, more focused modules?**
  _Cohesion score 0.08866995073891626 - nodes in this community are weakly interconnected._