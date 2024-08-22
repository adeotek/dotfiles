# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Set-up zsh
source $HOME/.config/zsh/config.zsh

export EDITOR="nvim"

# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
# pokemon-colorscripts --no-title -s -r

# Set-up icons for files/folders in terminal
alias ls='eza -a --icons'
alias ll='eza -al --icons'
alias lt='eza -a --tree --level=1 --icons'
alias pacman="sudo pacman"
alias apt="sudo apt"
alias systemctl="sudo systemctl"

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

neofetch
