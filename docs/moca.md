# moca (MO Coding Agent) — dotfiles setup

Config for [moca](https://github.com/adeotek/moca), a minimal, token-efficient,
provider-agnostic Go coding agent. Deployed to `$XDG_CONFIG_HOME/moca/`
(falling back to `~/.config/moca/`). **Not stowed** — files are copied by
`moca-setup.sh`, like the other AI tools.

## What gets deployed

| File | Destination | Behaviour on re-run |
|---|---|---|
| `moca/config.jsonc` | `moca/config.jsonc` | first run copied; on override **merged with `--live-wins`** |
| `moca/prompts/*.md` | `moca/prompts/` | seeded only if missing |

The merge (`moca/merge-moca-config.py`) keeps the live file authoritative: the
`model` written back by `/model`, a custom shell allowlist and extra providers
are never reset to the template, and the template only fills in missing keys.
moca itself rejects unknown keys (`DisallowUnknownFields`), so the template may
only contain documented ones.

## Install

```bash
./unattended_setup.sh --packages moca        # runs _scripts/core/moca-setup.sh
# or, interactively at the overwrite prompt:
./setup.sh                                    # pick moca under Console Extra
```

Both install the binary (`moca-install.sh`, via the official installer) and
deploy the config.

## Default configuration

`moca/config.jsonc` sets `model` (`opencode-go/glm-5.3-flash`) and `modelHard`
(`opencode-go/glm-5.3`), the three built-in providers, a shell allowlist, and
explicit defaults for `context`, `log`, `tui`, `web` and `snapshot`. Every key
is optional — the values only make the defaults visible and are safe to edit.

### Providers and credentials

Secrets never appear as literals: `apiKey` is an `env:VAR` reference, or is
omitted so the key stored by `/login` (TUI) or `moca login <provider>` in
`~/.config/moca/auth.json` is used. A stored key wins over the env reference.

### Ollama (local or LAN)

Name an `ollama/...` model, or add a `providers.ollama` entry, to enable it —
no API key and no model list, since moca discovers what the server has pulled.
The commented block in the template shows the three shapes:

```jsonc
"ollama": {}                                          // same machine, port 11434
"ollama": { "baseUrl": "http://nas.lan:11434" }       // another machine on the LAN
"ollama": { "models": { "qwen3:8b": { "contextWindow": 32768 } } }
```

Start the server with at least a 16K window
(`OLLAMA_CONTEXT_LENGTH=32768 ollama serve`); when its Modelfile has no
`num_ctx`, declare the same number with `contextWindow` or moca assumes 16384
and warns at startup.

## Slash commands (prompt templates)

`moca/prompts/` holds saved templates that run as `/<name>` in the TUI:

- **`/code-review`** — read-only review of a diff, branch or named files;
  severity-ordered findings with a file:line, a failure scenario and a fix,
  ending in an approve / request-changes verdict.
- **`/debug`** — find a failure's root cause before changing code: reproduce,
  trace the failing value to its origin, one hypothesis at a time, then fix and
  add a regression test.
- **`/document-code`** — document code from the code as it actually is: recon
  the existing docs pattern, write the contract and boundaries, verify every
  path/flag/sample quoted.

Each takes an argument (`/code-review main..HEAD`, `/debug "<error>"`,
`/document-code src/api`). A template that already exists is left alone, like
the `/create-command` template moca seeds itself.

## Update

```bash
./ai-tools-update.sh    # runs `moca update` (self-update from GitHub releases)
```
