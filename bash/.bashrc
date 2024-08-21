#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

### AdeoTEK start

export LC_ALL='C.UTF-8'
export EDITOR=nano
export PATH=$PATH:~/.local/bin

alias ll='ls -lAF'
alias vim="nvim"

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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

# Oh My Posh bash config
eval "$(oh-my-posh --init --shell bash --config ~/.config/oh-my-posh/gbs.omp.yaml)"
