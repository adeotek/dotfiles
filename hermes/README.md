# Hermes Agent

Hermes Agent is an AI agent CLI + gateway by Nous Research. This dotfiles module manages
its configuration, systemd services, and the `.env` credential store.

## Installation

Hermes is installed via the dotfiles setup script:

```bash
./unattended_setup.sh --packages hermes
```

Or manually:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Hermes Agent (this host)                                   │
│                                                             │
│  ┌─ gateway (systemd) ────────────────────────────────────┐ │
│  │  • Telegram bot                                         │ │
│  │  • API Server :8642  (OpenAI-compatible)                │ │
│  │  • Home Assistant integration                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─ dashboard (systemd) ──────────────────────────────────┐ │
│  │  • Web UI :9119                                         │ │
│  │  • Remote Desktop GUI backend                           │ │
│  │  • Auth: username/password (basic)                      │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
         ▲                          ▲
         │                          │
  ┌──────┴──────┐          ┌───────┴────────┐
  │ Windows CLI  │          │ Hermes Desktop  │
  │ (custom      │          │ GUI (Remote     │
  │  provider)   │          │  Gateway)       │
  └─────────────┘          └────────────────┘
```

## Configuration

### config.yaml

The full Hermes config. Managed by `hermes config` / `hermes model` interactively.
This template includes the current working setup:

- **Primary provider**: OpenCode Go (`deepseek-v4-pro`)
- **Fallback chain**: OpenRouter → custom (Ollama LAN) → OpenRouter Llama
- **Web search**: DuckDuckGo (search) + Firecrawl self-hosted (extract)
- **Terminal**: Local backend
- **Memory**: Enabled (built-in provider)
- **Delegation**: `deepseek-v4-flash` via OpenCode Go
- **Curator**: Weekly skill maintenance

### .env (credentials)

Copy `.env.template` to `~/.hermes/.env` and fill in the placeholders:

| Variable | Purpose |
|----------|---------|
| `OPENCODE_GO_API_KEY` | Primary LLM provider |
| `OPENROUTER_API_KEY` | Fallback LLM provider |
| `GOOGLE_API_KEY` | Gemini (TTS/STT fallback) |
| `FIRECRAWL_API_KEY` / `FIRECRAWL_API_URL` | Web extraction (self-hosted or cloud) |

## API Server (port 8642)

The gateway exposes an OpenAI-compatible HTTP endpoint. Any client that speaks
the OpenAI format (Open WebUI, LobeChat, curl, or another Hermes CLI) can use
the agent through this endpoint.

### Setup

Uncomment and configure in `~/.hermes/.env`:

```bash
API_SERVER_ENABLED=true
API_SERVER_KEY=<generate-with-openssl-rand-hex-32>
API_SERVER_HOST=0.0.0.0     # Bind to LAN (requires firewall rule)
```

### Usage (from a remote Hermes CLI on Windows/Linux/macOS)

```bash
hermes model          # → Custom endpoint
# URL:   http://<this-host>:8642/v1
# Key:   <API_SERVER_KEY>
# Model: hermes-agent
```

Or in `config.yaml`:

```yaml
model:
  default: hermes-agent
  provider: custom
  base_url: http://<this-host>:8642/v1
  api_key: <API_SERVER_KEY>
```

> **Note:** The `model` field is cosmetic — the actual LLM used is determined
> by the server's config.yaml. Tools run on the server, not the client.

### Opening the firewall

```bash
sudo firewall-cmd --permanent --add-port=8642/tcp
sudo firewall-cmd --reload
```

## Dashboard (port 9119)

The web dashboard serves the Hermes Web UI and acts as the backend for the
Hermes Desktop GUI's "Remote Gateway" feature.

### Setup

Uncomment and configure in `~/.hermes/.env`:

```bash
# Session token (quickest, for trusted LAN)
HERMES_DASHBOARD_SESSION_TOKEN=<generate-with-openssl-rand-hex-32>

# Or username/password (shows "Sign in" button in Desktop GUI)
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=<strong-password>
HERMES_DASHBOARD_BASIC_AUTH_SECRET=<generate-with-openssl-rand-base64-32>
```

Then start the service:

```bash
systemctl --user enable --now hermes-dashboard
```

### Opening the firewall

```bash
sudo firewall-cmd --permanent --add-port=9119/tcp
sudo firewall-cmd --reload
```

### Connecting the Desktop GUI

In the Hermes Desktop app:

1. **Settings → Gateway → Remote Gateway**
2. Select **"Remote gateway"** mode
3. **Remote URL**: `http://<this-host>:9119`
4. If username/password is configured, click **"Sign in"** → enter credentials
5. If using session token, paste it in the token field
6. **Save and reconnect**

## Systemd Services

User-level systemd units managed by this dotfiles module:

| Unit | Port | Description |
|------|------|-------------|
| `hermes-gateway.service` | 8642 | Telegram bot + API Server |
| `hermes-dashboard.service` | 9119 | Web UI + Remote Desktop backend |
| `hermes-update.timer` + `.service` | — | Daily `hermes update` at 08:00 local |
| `hermes-update-notify.service` | — | Telegram failure notifications for the update job |

### Management

```bash
# Gateway
systemctl --user status hermes-gateway
systemctl --user restart hermes-gateway
journalctl --user -u hermes-gateway -f

# Dashboard
systemctl --user status hermes-dashboard
systemctl --user restart hermes-dashboard
journalctl --user -u hermes-dashboard -f
```

### Service files location

The templates are in `<dotfiles>/hermes/.config/systemd/user/`. They use
`<HERMES_*>` placeholders that the setup script resolves to absolute paths.

### Daily update (`hermes-update.timer`)

Fires `hermes-update.service` every day at 08:00 local time
(`OnCalendar=*-*-* 08:00:00`; `Persistent=true` catches up if the host was
off at 08:00). It runs as its own unit — outside the gateway cgroup — so
`hermes update` can safely drain and restart the gateway fleet without
killing its own process. Support scripts deploy to `~/.hermes/scripts/`
(templates in `hermes/.hermes/scripts/`).

Behavior:
- Already up to date → silent (full log in the journal)
- New version pulled → Telegram ✅ ping with the commit range
- Update failed → Telegram ⚠️ ping with the exit code
- Unit-level failure (timeout, start failure) → `OnFailure` fires the notifier unit

```bash
systemctl --user daemon-reload
systemctl --user enable --now hermes-update.timer
```

> **Important:** `systemctl restart` from inside the gateway process is
> blocked (the agent can't kill itself). Run restart commands from an SSH
> session or a separate terminal.

## Provider Reference

| Provider | Auth | Key env var |
|----------|------|-------------|
| OpenCode Go | API key | `OPENCODE_GO_API_KEY` |
| OpenRouter | API key | `OPENROUTER_API_KEY` |
| Anthropic | API key | `ANTHROPIC_API_KEY` |
| Google Gemini | API key | `GOOGLE_API_KEY` |
| DeepSeek | API key | `DEEPSEEK_API_KEY` |
| Custom (any OpenAI-compatible) | API key | user-defined |

## Documentation

<https://hermes-agent.nousresearch.com/docs>
