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

export LC_ALL='C.UTF-8'
export EDITOR="nvim"
export PATH=$PATH:~/.local/bin

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r

# Set-up icons for files/folders in terminal
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


HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Oh My Zsh (optional)
#source $DIR/plugins/oh-my-zsh.zsh

# # Starship
# export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
# eval "$(starship init zsh)"

# Oh My Posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/gbs.omp.yaml)"

# FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"

# yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# start neofetch
neofetch

