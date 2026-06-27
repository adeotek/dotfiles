# Hermes Agent

Hermes Agent is an AI agent CLI by Nous Research.

## Installation

Hermes is installed via the dotfiles setup script:

```bash
./unattended_setup.sh --packages hermes
```

Or manually:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

## Headroom integration

When Hermes is installed through this dotfiles setup, it is automatically configured to route LLM traffic through the Headroom proxy:

- `~/.hermes/.env` contains `OPENAI_BASE_URL` and `ANTHROPIC_BASE_URL` pointing to `http://localhost:8787`
- `~/.hermes/config.yaml` uses `provider: "main"` which reads those environment variables
- All auxiliary tasks (vision, web_extract, compression, skills_hub, MCP) also route through Headroom

## Supported providers

Hermes works with any provider supported by Headroom:

- **OpenAI API** — `provider: "main"` (uses `OPENAI_BASE_URL`)
- **Anthropic API** — `provider: "anthropic"` (uses `ANTHROPIC_BASE_URL`)
- **OpenRouter** — `provider: "openrouter"` (Hermes handles its own OpenRouter integration)
- **OpenCode Zen** — `provider: "main"` with `OPENAI_TARGET_API_URL=https://opencode.ai/zen/v1`
- **Google Gemini** — `provider: "gemini"` (uses `GOOGLE_API_KEY`)
- **GitHub Copilot** — `provider: "copilot"` (uses `GITHUB_TOKEN`)

To switch the Headroom proxy target, edit `~/.config/headroom/proxy.env` and restart:

```bash
systemctl --user restart headroom-proxy
```

## Bypassing the proxy

If you need to bypass Headroom for a specific Hermes command:

```bash
unset OPENAI_BASE_URL ANTHROPIC_BASE_URL
hermes chat
```

## Documentation

<https://hermes-agent.nousresearch.com/docs>
