# Zed — stowed config + setup notes

Stow package: `zed/` → `~/.config/zed/` (settings.json only — no keymap.json in the
package; per-machine keybindings should be added via Zed's UI so they don't clash
with stow).

## What `settings.json` contains

- `base_keymap: "VSCode"` — VS Code muscle memory transfers directly.
- One Dark theme, 16px UI/buffer fonts, tab size 2.
- `telemetry` off (diagnostics + metrics). Delete these two keys if you want
  Zed to send crash diagnostics/usage metrics.
- `agent_servers.OpenCode` — registers **OpenCode** as an ACP agent
  (`opencode acp`, per https://opencode.ai/docs/acp/). Requires `opencode` on
  PATH (provisioned by the `opencode` setup task). Open it via the Agent Panel
  → new thread → **OpenCode**. Uses OpenCode's own auth/config
  (`~/.config/opencode`) — **no keys live in this repo**.

## Per-machine setup (not stowable — do once per machine)

1. Extensions: `zed: extensions` in the command palette. Useful for this stack:
   `C#`, `Dockerfile`, `Terraform`, `SQL`, `PowerShell`, `Angular` (zed-angular),
   `Emmet`, `One Dark Pro`.
2. **Claude Code** as an agent: run `zed: acp registry` and install the
   **Claude** agent (interactive, registers itself in your local settings).
   Do **not** install the old `@zed-industries/claude-code-acp` npm adapter —
   deprecated Feb 2026 (current successor package:
   `@agentclientprotocol/claude-agent-acp`, only if you ever need a manual
   custom agent). Claude Code uses its own auth (`~/.claude`) — no keys in
   this repo.

## House rules

- **Never commit secrets/IDs here** — this repo is public. Agent keys,
  tokens, and private endpoints belong in the agents' own local configs
  (`~/.opencode`, `~/.claude`, shell env), never in `zed/`.
- Machine-specific overrides: keep them out of the stowed file; use Zed's
  local settings if you need per-host differences.
- Switching from VS Code: https://zed.dev/docs/migrate/vs-code