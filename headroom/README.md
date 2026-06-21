# Headroom

Headroom is an LLM context compression proxy that runs as a systemd user service. All LLM traffic from OpenCode, Hermes Agent, and other compatible tools flows through it automatically.

## Installation

```bash
# Via the dotfiles setup script:
./unattended_setup.sh --packages headroom

# Or manually via uv:
uv tool install --python python3.13 'headroom-ai[all]'
```

## Compatible tools

- **OpenCode** — uses `ANTHROPIC_BASE_URL` / `OPENAI_BASE_URL`
- **Hermes Agent** — uses `ANTHROPIC_BASE_URL` / `OPENAI_BASE_URL` (via `provider: "main"` or `provider: "anthropic"`)
- **Claude Code** — `ANTHROPIC_BASE_URL=http://localhost:8787 claude`
- **Any OpenAI-compatible client** — `OPENAI_BASE_URL=http://localhost:8787/v1 <command>`

## Supported LLM providers

Headroom natively supports the following providers via the proxy:

| Provider | Support | Configuration |
|----------|---------|-------------|
| **OpenAI API** | Native | Default — no extra config needed |
| **Anthropic API** | Native | Default — no extra config needed |
| **OpenRouter** | `--backend openrouter` | Set `OPENROUTER_API_KEY` in `~/.config/headroom/proxy.env` |
| **OpenCode Zen** | OpenAI-compatible | Set `OPENAI_TARGET_API_URL=https://opencode.ai/zen/v1` in `proxy.env` |
| **Google Gemini / Vertex AI** | `--backend vertex_ai` | Set `GOOGLE_APPLICATION_CREDENTIALS` for Vertex AI |
| **GitHub Copilot** | `headroom wrap copilot` | Use wrapper command (see below) |

### Important: one backend at a time

The Headroom proxy forwards to **one** OpenAI-compatible backend per instance. To switch providers:

```bash
# 1. Edit the provider config
nano ~/.config/headroom/proxy.env

# 2. Restart the proxy
systemctl --user restart headroom-proxy
```

### Multi-provider setup

To use multiple providers simultaneously, run additional proxy instances on different ports:

```bash
# Terminal 1: OpenRouter
headroom proxy --port 8788 --backend openrouter

# Terminal 2: OpenCode Zen
headroom proxy --port 8789 --openai-api-url https://opencode.ai/zen/v1

# Then point different tools at different ports:
OPENAI_BASE_URL=http://localhost:8788/v1 opencode
OPENAI_BASE_URL=http://localhost:8789/v1 hermes chat
```

### Provider-specific setup

#### OpenRouter

```bash
# ~/.config/headroom/proxy.env
OPENROUTER_API_KEY=sk-or-...
OPENAI_TARGET_API_URL=https://openrouter.ai/api/v1
```

Then restart the proxy:

```bash
systemctl --user restart headroom-proxy
```

#### OpenCode Zen

```bash
# ~/.config/headroom/proxy.env
OPENAI_TARGET_API_URL=https://opencode.ai/zen/v1
# For Claude models via Zen, also set:
# ANTHROPIC_BASE_URL=https://opencode.ai/zen/v1
```

Then restart the proxy.

#### Google Gemini / Vertex AI

For Google Cloud Vertex AI:

```bash
# ~/.config/headroom/proxy.env
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account-key.json
```

Then edit the systemd service to add `--backend vertex_ai`:

```bash
systemctl --user edit headroom-proxy.service --drop-in=override.conf
# Add:
# [Service]
# ExecStart=
# ExecStart=%h/.local/bin/headroom proxy --host 0.0.0.0 --port 8787 --backend vertex_ai
```

For Google AI Studio (OpenAI-compatible endpoint):

```bash
# ~/.config/headroom/proxy.env
OPENAI_TARGET_API_URL=https://generativelanguage.googleapis.com/v1beta
```

#### GitHub Copilot

Copilot uses its own auth and endpoint. Use the Headroom wrapper:

```bash
headroom wrap copilot -- --model gpt-4o
```

Or for Claude models via Copilot:

```bash
headroom wrap copilot -- --model claude-sonnet-4-20250514
```

## How it works

- The proxy listens on `http://localhost:8787`
- Environment variables (`ANTHROPIC_BASE_URL`, `OPENAI_BASE_URL`) route all LLM traffic through the proxy
- Headroom compresses tool outputs, logs, search results, and other context before sending to the LLM
- Typical savings: 40-90% fewer input tokens with no loss in answer quality

## Service management

```bash
# Check status
systemctl --user status headroom-proxy

# Start/stop/restart
systemctl --user start headroom-proxy
systemctl --user stop headroom-proxy
systemctl --user restart headroom-proxy

# View logs
journalctl --user -u headroom-proxy -f

# Disable auto-start
systemctl --user disable headroom-proxy
```

## Stats and monitoring

```bash
# Live stats (session + persistent)
curl http://localhost:8787/stats

# Health check
curl http://localhost:8787/health

# Prometheus metrics
curl http://localhost:8787/metrics
```

## Bypassing the proxy

If you need to bypass Headroom for a specific command:

```bash
unset ANTHROPIC_BASE_URL OPENAI_BASE_URL
opencode
```

## Configuration

- `~/.config/headroom/proxy.env` — provider-specific configuration (API keys, target URLs)
- `~/.headroom/models.json` — custom model context limits and pricing
- `~/.config/systemd/user/headroom-proxy.service` — systemd service configuration
- Environment variables: `HEADROOM_LOG_LEVEL` (INFO, DEBUG, WARN, ERROR), `HEADROOM_TELEMETRY` (on/off)

## Documentation

<https://headroom-docs.vercel.app/docs>
