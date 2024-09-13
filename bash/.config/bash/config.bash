# Bash configuration file

export PATH=$PATH:$HOME/.local/bin

# homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  export PATH=/home/linuxbrew/.linuxbrew/opt/node@20/bin:$PATH
fi

# GO lang
if [ -d "$PATH:$HOME/go/bin" ]; then
  export PATH="$PATH:$HOME/go/bin"
fi

# dotnet tools
if [ -d "$HOME/.dotnet/tools" ]; then
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

export LC_ALL='C.UTF-8'
export EDITOR="nvim"
export PATH=$PATH:~/.local/bin

if $(command -v eza >/dev/null 2>&1); then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons'
  alias lt='eza -a --tree --level=1 --icons'
else
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias ll='ls -lAF'
fi
alias pacman="sudo pacman"
alias apt="sudo apt"
alias systemctl="sudo systemctl"
alias vim="nvim"

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
eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/gbs.omp.yaml)"

# Starship
#eval "$(starship init bash)"
