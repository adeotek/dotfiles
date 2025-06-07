# Bash configuration file

export PATH=$PATH:$HOME/.local/bin

# homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # NodeJs
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@20/bin" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/node@20/bin:$PATH"
  fi
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@22/bin" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/node@22/bin:$PATH"
  fi
fi

# Rust
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# GO lang
if [ -d "/usr/local/go/bin" ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi
if [ -d "$HOME/go/bin" ]; then
  export PATH="$PATH:$HOME/go/bin"
fi

# dotnet & dotnet tools
if [ -d "$HOME/.dotnet" ]; then
  # export DOTNET_ROOT=$HOME/.dotnet
  export PATH=$PATH:$HOME/.dotnet
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

export PATH=$PATH:~/.local/bin
export LC_ALL='C.UTF-8'
export EDITOR="nano"

# Neovim
if $(command -v nvim >/dev/null 2>&1); then
  alias vim="nvim"
fi

# EZA
if $(command -v eza >/dev/null 2>&1); then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons'
  alias lt='eza -a --tree --level=1 --icons'
else
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias ll='ls -lAF'
fi

alias dud="du -h --max-depth=1 | sort -hr"
alias systemctl="sudo systemctl"
alias dc='docker compose'
case "$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)" in
  arch)
    alias pacman="sudo pacman"
    ;;
  debian|ubuntu|pop)
    alias apt="sudo apt"
    ;;
  fedora|redhat|centos|almalinux)
    alias dnf="sudo dnf"
    ;;
esac

# FZF key bindings (CTRL R for fuzzy history finder)
# Setup fzf
if [[ -d /home/dev/.fzf/bin && ! "$PATH" == */home/dev/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/dev/.fzf/bin"
fi
if [[ -x "$(command -v fzf)" ]]; then
  eval "$(fzf --bash)"
  alias searchf='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  alias dpsfzf='docker ps -a | fzf --preview "docker inspect {1}"'
fi

# zoxide
if $(command -v zoxide >/dev/null 2>&1); then
  eval "$(zoxide init bash)"
fi

# yazi
if $(command -v yazi >/dev/null 2>&1); then
  function yy() {
    local tmp="/tmp/yazi-cwd.wDMzCh"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi


# Oh My Posh bash config
if $(command -v oh-my-posh >/dev/null 2>&1); then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/gbs.omp.yaml)"
fi

# Starship
# if $(command -v starship >/dev/null 2>&1); then
#   eval "$(starship init bash)"
# fi
