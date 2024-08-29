#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# dotnet tools
export PATH="$PATH:$HOME/.dotnet/tools"

# Load config and plugins
source $HOME/.config/bash/config.bash

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
