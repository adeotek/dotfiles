# Paseo daemon (dotfiles template)

Agent-orchestrator daemon for coding agent CLIs (Claude Code, Hermes via ACP, ...).
Config lives at `~/.paseo/config.json` (NOT stowed — contains daemon auth hash).

## Install

```bash
# 1. CLI (allow esbuild/node-pty install scripts)
npm install -g --allow-scripts=esbuild,node-pty @getpaseo/cli

# 2. systemd user unit
mkdir -p ~/.config/systemd/user
cp .config/systemd/user/paseo-daemon.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now paseo-daemon

# 3. daemon password (writes bcrypt hash to ~/.paseo/config.json, then restart)
paseo daemon set-password
systemctl --user restart paseo-daemon
```

## Notes

- Listens 0.0.0.0:6767; firewalld public zone needs 6767/tcp.
- Relay disabled by default (LAN direct only).
- Hermes: add under `agents.providers` in `~/.paseo/config.json`:
  `{ "extends": "acp", "label": "Hermes", "command": ["hermes", "acp"] }`
- Mobile app: Settings → Add host → Direct connection → host:6767 (+ password).
- CLI with password: `PASEO_PASSWORD=... paseo ls`
