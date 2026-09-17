# ZSH Configuration

`config.zsh` is the single ZSH config, deployed by `_scripts/core/zsh-setup.sh`
(stowed to `~/.config/zsh/` and sourced from `~/.zshrc`).

## Plugins

Managed by [antidote](https://antidote.sh). The plugin list lives in
`.config/zsh/zsh_plugins.txt`:

- `belak/zsh-utils path:completion` — completion framework (`compinit`)
- `zsh-users/zsh-autosuggestions` — suggestions from history/completions
- `zsh-users/zsh-syntax-highlighting` — command-line highlighting
- `zsh-users/zsh-history-substring-search` — Up/Down search on typed prefix

On shell start, `config.zsh` regenerates the static bundle
(`antidote bundle < zsh_plugins.txt`) into
`~/.cache/zsh/zsh_plugins.zsh` only when `zsh_plugins.txt` is newer, then
sources it. To update plugins: `antidote update`.

## Highlights

- History: 50k entries, shared, deduplicated, timestamped (`~/.local/share/zsh/.zsh_history`)
- PATH: deduplicated (`typeset -U path`), `$HOME/.local/bin` prepended
- Prompt: Starship by default (`OPT_ZSH_DEFAULT_PROMPT`); oh-my-posh selectable via the interactive setup (`--prompt`)
- Integrations: fzf, zoxide, yazi (`yy` wrapper), mise, eza, bat as `MANPAGER`
- Key bindings: emacs mode, Ctrl+arrows word-jump, Ctrl+Space accept suggestion

## Customization

Put personal overrides in `~/.zshrc.local` (untracked) — it is sourced last.

## Troubleshooting

- Completions broken: `rm ~/.zcompdump*; exec zsh`
- Slow startup: `zprof`
