# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Ctrl-Left]="${terminfo[kLFT5]}"
key[Ctrl-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"       ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"        ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"     ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}"  ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"     ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"         ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"       ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"       ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"      ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"     ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"   ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}"  ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n "${key[Ctrl-Left]}"  ]] && bindkey -- "${key[Ctrl-Left]}"  backward-word
[[ -n "${key[Ctrl-Right]}" ]] && bindkey -- "${key[Ctrl-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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
  export DOTNET_ROOT=$HOME/.dotnet
  export PATH=$PATH:$HOME/.dotnet
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

export PATH=$PATH:~/.local/bin
export LC_ALL='C.UTF-8'

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r

# Neovim
if $(command -v nvim >/dev/null 2>&1); then
  export EDITOR="nvim"
  alias vim="nvim"
else
  export EDITOR="nano"
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

alias systemctl="sudo systemctl"
case "$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)" in
  arch)
    alias pacman="sudo pacman"
    ;;
  debian|ubuntu)
    alias apt="sudo apt"
    ;;
  ubuntu)
    alias dnf="sudo dnf"
    ;;
esac

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# FZF key bindings (CTRL R for fuzzy history finder)
# Setup fzf
if [[ -d /home/dev/.fzf/bin && ! "$PATH" == */home/dev/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/dev/.fzf/bin"
fi
if [[ -x "$(command -v fzf)" ]]; then
  source <(fzf --zsh)
  alias searchf='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  alias dpsfzf='docker ps -a | fzf --preview "docker inspect {1}"'
fi

# zoxide
if $(command -v zoxide >/dev/null 2>&1); then
  eval "$(zoxide init zsh)"
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

# Oh My Zsh (optional)
# source $DIR/plugins/oh-my-zsh.zsh

# Oh My Posh bash config
if $(command -v oh-my-posh >/dev/null 2>&1); then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/gbs.omp.yaml)"
fi

# Starship
# if $(command -v starship >/dev/null 2>&1); then
#   export STARSHIP_CONFIG=$CURRENT_CONFIG_DIR/starship/starship.toml
#   eval "$(starship init zsh)"
# fi

# start neofetch
neofetch
