# Bash configuration file

export COLORTERM=truecolor
export LC_ALL="${LC_ALL:-C.UTF-8}"
export EDITOR="nano"

# Global alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'
# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'

# PATH helpers: prepend/append only if the dir is not already present (dedup on re-source)
path_prepend() { [[ ":$PATH:" == *":$1:"* ]] || PATH="$1${PATH:+:$PATH}"; }
path_append()  { [[ ":$PATH:" == *":$1:"* ]] || PATH="${PATH:+$PATH:}$1"; }

path_prepend "$HOME/.local/bin"

# Add .tools to path if it exists
if [ -d "$HOME/.tools" ]; then
  path_append "$HOME/.tools"
fi

# homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # NodeJs
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@22/bin" ]; then
    path_prepend "/home/linuxbrew/.linuxbrew/opt/node@22/bin"
  fi
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@24/bin" ]; then
    path_prepend "/home/linuxbrew/.linuxbrew/opt/node@24/bin"
  fi
fi

# Rust
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# GO lang
if [ -d "/usr/local/go/bin" ]; then
  path_append "/usr/local/go/bin"
fi
if [ -d "$HOME/go/bin" ]; then
  export GOPATH="$HOME/go"
  path_append "$GOPATH/bin"
fi

# dotnet & dotnet tools
if [ -d "$HOME/.dotnet" ]; then
  # export DOTNET_ROOT=$HOME/.dotnet
  path_append "$HOME/.dotnet"
  path_append "$HOME/.dotnet/tools"
fi

# Neovim
if command -v nvim >/dev/null 2>&1; then
  alias vim="nvim"
fi

# EZA
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons'
  alias lt='eza -a --tree --level=1 --icons'
else
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
  alias ll='ls -lAF'
fi

alias dud="du -h --max-depth=1 | sort -hr"
alias service='sudo systemctl'
alias d='docker'
alias dc='docker compose'
case "$(awk -F '=' '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release)" in
  arch)
    alias pacman="sudo pacman"
    ;;
  debian|ubuntu|pop)
    alias apt="sudo apt"
    ;;
  fedora|redhat)
    alias dnf="sudo dnf"
    ;;
esac

# hstr configuration
if command -v hstr >/dev/null 2>&1; then
  # HSTR configuration - add this to ~/.bashrc
  alias hh=hstr                    # hh to be alias for hstr
  export HSTR_CONFIG=hicolor       # get more colors
  shopt -s histappend              # append new history items to .bash_history
  export HISTCONTROL=ignorespace   # leading space hides commands from history
  export HISTFILESIZE=10000        # increase history file size (default is 500)
  export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
  # ensure synchronization between bash memory and history file
  export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
  function hstrnotiocsti {
      { READLINE_LINE="$( { </dev/tty hstr ${READLINE_LINE}; } 2>&1 1>&3 3>&- )"; } 3>&1;
      READLINE_POINT=${#READLINE_LINE}
  }
  # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
  if [[ $- =~ .*i.* ]]; then bind -x '"\C-r": "hstrnotiocsti"'; fi
  export HSTR_TIOCSTI=n
fi

# FZF key bindings (CTRL R for fuzzy history finder)
# Setup fzf
if [[ -d "$HOME/.fzf/bin" && ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi
if [[ -x "$(command -v fzf)" ]]; then
  eval "$(fzf --bash)"
  alias searchf='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  alias dpsfzf='docker ps -a | fzf --preview "docker inspect {1}"'
fi

# yazi
if command -v yazi >/dev/null 2>&1; then
  function yy() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    command rm -f -- "$tmp"
  }
fi

# Cloud CLI tools
if command -v gcloud >/dev/null 2>&1; then
  # gcloud
  alias gc="gcloud"
  alias gcl="gcloud"
  # export CLOUDSDK_PYTHON_SITEPACKAGES=1
  # export CLOUDSDK_ACTIVE_CONFIG_NAME=default
  # export CLOUDSDK_CORE_DISABLE_PROMPTS=1
  # export CLOUDSDK_CORE_LOGGING_LEVEL=info
fi
if command -v terraform >/dev/null 2>&1; then
  # terraform
  alias tf="terraform"
  alias tfa='terraform apply'
  alias tff='terraform fmt'
  alias tfp='terraform plan'
fi

# Prompt (per-machine choice in ~/.config/bash/prompt-tool; defaults to oh-my-posh)
_prompt_tool="$(cat ~/.config/bash/prompt-tool 2>/dev/null || echo oh-my-posh)"
if [[ "$_prompt_tool" == "starship" ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
elif command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/gbs.omp.yaml)"
fi
unset _prompt_tool

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# AI tools configuration
[ -f "${HOME}/.config/bash/ai-config.bash" ] && source "${HOME}/.config/bash/ai-config.bash"

if [[ -f "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME"/.local/bin/mise activate bash)" # added by https://mise.run/bash
fi

# Local overrides (untracked)
[ -f "$HOME/.bashrc.local" ] && source "$HOME/.bashrc.local"
