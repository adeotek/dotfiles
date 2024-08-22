# Bash configuration file

# zoxide
eval "$(zoxide init bash)"

# yazi
function yy() {
  local tmp="/tmp/yazi-cwd.wDMzCh"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# FZF key bindings (CTRL R for fuzzy history finder)
eval "$(fzf --bash)"

# Oh My Posh bash config
eval "$(oh-my-posh --init --shell bash --config ~/.config/oh-my-posh/gbs.omp.yaml)"

# Starship
#eval "$(starship init bash)"
