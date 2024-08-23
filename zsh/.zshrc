# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Set-up zsh
source $HOME/.config/zsh/config.zsh

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

# start neofetch
neofetch

