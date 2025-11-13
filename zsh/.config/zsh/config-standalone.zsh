# =============================================================================
# Standalone ZSH Configuration
# A comprehensive, self-contained ZSH setup without plugin managers
# Features: Git, Docker, Autocomplete, History, Syntax Highlighting, and more
# =============================================================================

# -----------------------------------------------------------------------------
# General Settings
# -----------------------------------------------------------------------------
export LC_ALL='C.UTF-8'
export LANG='en_US.UTF-8'
export EDITOR="nano"
export VISUAL="$EDITOR"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTFILE="${XDG_DATA_HOME}/zsh/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# Create history directory if it doesn't exist
mkdir -p "$(dirname "$HISTFILE")"

# History options
setopt EXTENDED_HISTORY          # Record timestamp of command in HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST    # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS          # Ignore duplicated commands history list
setopt HIST_IGNORE_SPACE         # Ignore commands that start with space
setopt HIST_VERIFY               # Show command with history expansion before running it
setopt HIST_SAVE_NO_DUPS         # Don't save duplicate commands
setopt INC_APPEND_HISTORY        # Add commands to HISTFILE immediately, not when shell exits
setopt SHARE_HISTORY             # Share command history between all sessions

# -----------------------------------------------------------------------------
# Completion System
# -----------------------------------------------------------------------------
# Initialize completion system
autoload -Uz compinit

# Speed up compinit by checking cache once a day
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion options
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to the end of a completed word
setopt PATH_DIRS           # Perform path search even on command names with slashes
setopt AUTO_MENU           # Show completion menu on a successive tab press
setopt AUTO_LIST           # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash
setopt NO_MENU_COMPLETE    # Do not autoselect the first completion entry
setopt NO_FLOW_CONTROL     # Disable start/stop characters in shell editor

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/.zcompcache"

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Fuzzy matching
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# SSH/SCP/RSYNC completion
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr

# Docker completion
if command -v docker >/dev/null 2>&1; then
  zstyle ':completion:*:*:docker:*' option-stacking yes
  zstyle ':completion:*:*:docker-*:*' option-stacking yes
fi

# -----------------------------------------------------------------------------
# Directory Navigation
# -----------------------------------------------------------------------------
setopt AUTO_CD              # Auto changes to a directory without typing cd
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given
setopt CDABLE_VARS          # Change directory to a path stored in a variable
setopt MULTIOS              # Write to multiple descriptors
setopt EXTENDED_GLOB        # Use extended globbing syntax

# Directory stack
DIRSTACKSIZE=20
setopt autopushd pushdsilent pushdtohome

# Aliases for directory navigation
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias d='dirs -v | head -10'

# -----------------------------------------------------------------------------
# PATH Configuration
# -----------------------------------------------------------------------------
# Add common directories to PATH
typeset -U path  # Keep only unique entries in path
path=(
  $HOME/.local/bin
  $HOME/bin
  /usr/local/bin
  /usr/local/sbin
  $path
)

# Homebrew
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # NodeJs from Homebrew
  for node_version in node@{22,24,20}; do
    if [[ -d "/home/linuxbrew/.linuxbrew/opt/$node_version/bin" ]]; then
      path=("/home/linuxbrew/.linuxbrew/opt/$node_version/bin" $path)
      break
    fi
  done
fi

# Rust
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Go
[[ -d "/usr/local/go/bin" ]] && path+=("/usr/local/go/bin")
[[ -d "$HOME/go/bin" ]] && path+=("$HOME/go/bin")

# .NET
if [[ -d "$HOME/.dotnet" ]]; then
  path+=("$HOME/.dotnet" "$HOME/.dotnet/tools")
fi

# FZF
[[ -d "$HOME/.fzf/bin" ]] && path+=("$HOME/.fzf/bin")

# -----------------------------------------------------------------------------
# Git Integration
# -----------------------------------------------------------------------------
# Load git information functions
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Configure vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr '%F{green}●%f'
zstyle ':vcs_info:*' unstagedstr '%F{red}●%f'
zstyle ':vcs_info:git:*' formats ' %F{blue}(%f%F{cyan}%b%f%c%u%F{blue})%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}(%f%F{cyan}%b%f%F{yellow}|%a%f%c%u%F{blue})%f'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcm='git commit -m'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcam='git commit -a -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gr='git restore'
alias grs='git restore --staged'
alias gst='git status'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsw='git switch'
alias gswc='git switch -c'

# -----------------------------------------------------------------------------
# Docker Integration
# -----------------------------------------------------------------------------
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop'
alias dstart='docker start'
alias drestart='docker restart'
alias dpull='docker pull'
alias dbuild='docker build'
alias dprune='docker system prune -a'

# Docker compose aliases
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcrestart='docker compose restart'
alias dclogs='docker compose logs'
alias dclogsf='docker compose logs -f'
alias dcps='docker compose ps'
alias dcbuild='docker compose build'
alias dcpull='docker compose pull'

# -----------------------------------------------------------------------------
# General Aliases
# -----------------------------------------------------------------------------
# Basic commands
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Enhanced ls (use eza if available, otherwise standard ls)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons --git'
  alias la='eza -a --icons'
  alias lt='eza -a --tree --level=2 --icons'
  alias lta='eza -a --tree --icons'
else
  alias ll='ls -lAhF'
  alias la='ls -A'
fi

# Safety aliases
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias mkdir='mkdir -pv'

# Utilities
alias dud='du -h --max-depth=1 | sort -hr'
alias df='df -h'
alias free='free -h'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias wget='wget -c'
alias path='echo -e ${PATH//:/\\n}'

# System management
alias service='sudo systemctl'
alias sctl='sudo systemctl'
alias jctl='sudo journalctl'

# Package manager aliases based on OS
if [[ -f /etc/os-release ]]; then
  OS_ID=$(awk -F '=' '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release)
  case "$OS_ID" in
    arch)
      alias pacman='sudo pacman'
      alias update='sudo pacman -Syu'
      ;;
    debian|ubuntu|pop)
      alias apt='sudo apt'
      alias update='sudo apt update && sudo apt upgrade'
      ;;
    fedora|redhat|centos|almalinux)
      alias dnf='sudo dnf'
      alias update='sudo dnf upgrade'
      ;;
  esac
fi

# -----------------------------------------------------------------------------
# Enhanced Functions
# -----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"    ;;
      *.tar.gz)    tar xzf "$1"    ;;
      *.tar.xz)    tar xJf "$1"    ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.gz)        gunzip "$1"     ;;
      *.tar)       tar xf "$1"     ;;
      *.tbz2)      tar xjf "$1"    ;;
      *.tgz)       tar xzf "$1"    ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"       ;;
      *.rar)       unrar x "$1"    ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick find
ff() {
  find . -type f -name "*$1*"
}

fd() {
  find . -type d -name "*$1*"
}

# Quick grep in current directory
gg() {
  grep -r "$1" .
}

# Calculator
calc() {
  echo "scale=3; $*" | bc -l
}

# Weather
weather() {
  local city="${1:-}"
  curl "wttr.in/${city}"
}

# Cheat sheet
cheat() {
  curl "cheat.sh/$1"
}

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------
# Use emacs-style key bindings
bindkey -e

# History search
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search      # Up arrow
bindkey '^[[B' down-line-or-beginning-search    # Down arrow
bindkey '^P' up-line-or-beginning-search        # Ctrl+P
bindkey '^N' down-line-or-beginning-search      # Ctrl+N

# Modern key bindings
bindkey '^[[H' beginning-of-line                # Home
bindkey '^[[F' end-of-line                      # End
bindkey '^[[3~' delete-char                     # Delete
bindkey '^[[1;5C' forward-word                  # Ctrl+Right
bindkey '^[[1;5D' backward-word                 # Ctrl+Left
bindkey '^H' backward-delete-word               # Ctrl+Backspace
bindkey '^[[3;5~' kill-word                     # Ctrl+Delete

# Edit command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line                # Ctrl+X Ctrl+E

# -----------------------------------------------------------------------------
# Syntax Highlighting (Inline Implementation)
# -----------------------------------------------------------------------------
# Try to load external syntax highlighting if available
if [[ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  # Basic inline syntax highlighting using ZLE
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
fi

# -----------------------------------------------------------------------------
# Auto-Suggestions (Inline Implementation)
# -----------------------------------------------------------------------------
# Try to load external autosuggestions if available
if [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
elif [[ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
elif [[ -f "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# Accept autosuggestion with Ctrl+Space
bindkey '^ ' autosuggest-accept

# -----------------------------------------------------------------------------
# FZF Integration
# -----------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  # Initialize fzf
  if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
  else
    # Inline fzf key bindings
    eval "$(fzf --zsh 2>/dev/null)" || true
  fi

  # FZF options
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
    --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
    --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
    --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
  "

  # Use fd or find for file searching
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  elif command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  # FZF preview with bat or cat
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=header,grid --line-range :500 {}'"
    alias preview='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  else
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
    alias preview='fzf --preview "cat {}"'
  fi

  export FZF_ALT_C_OPTS="--preview 'ls -lh {}'"

  # Custom FZF functions
  # Search and edit file
  fe() {
    local file
    file=$(fzf --preview 'bat --color=always --style=header,grid {}' --preview-window=right:60%:wrap) && ${EDITOR} "$file"
  }

  # Change directory using fzf
  fcd() {
    local dir
    dir=$(fd --type d | fzf --preview 'ls -lh {}') && cd "$dir"
  }

  # Kill process
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "$pid" | xargs kill -${1:-9}
    fi
  }

  # Docker container selection
  if command -v docker >/dev/null 2>&1; then
    fdex() {
      local container
      container=$(docker ps -a | fzf --header-lines=1 | awk '{print $1}')
      [[ -n "$container" ]] && docker exec -it "$container" "${1:-sh}"
    }

    fdlog() {
      local container
      container=$(docker ps -a | fzf --header-lines=1 | awk '{print $1}')
      [[ -n "$container" ]] && docker logs -f "$container"
    }
  fi
fi

# -----------------------------------------------------------------------------
# Zoxide (Smart cd)
# -----------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# -----------------------------------------------------------------------------
# Yazi Integration
# -----------------------------------------------------------------------------
if command -v yazi >/dev/null 2>&1; then
  function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# -----------------------------------------------------------------------------
# Command Not Found Handler
# -----------------------------------------------------------------------------
if [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
  source /usr/share/doc/pkgfile/command-not-found.zsh
elif [[ -f /etc/zsh_command_not_found ]]; then
  source /etc/zsh_command_not_found
fi

# -----------------------------------------------------------------------------
# Neovim
# -----------------------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
  export EDITOR='nvim'
  export VISUAL='nvim'
fi

# -----------------------------------------------------------------------------
# Cloud CLI Tools
# -----------------------------------------------------------------------------
# Google Cloud SDK
if command -v gcloud >/dev/null 2>&1; then
  alias gc='gcloud'
  alias gcl='gcloud'
fi

# Terraform
if command -v terraform >/dev/null 2>&1; then
  alias tf='terraform'
  alias tfa='terraform apply'
  alias tff='terraform fmt'
  alias tfi='terraform init'
  alias tfp='terraform plan'
  alias tfv='terraform validate'
fi

# Kubectl
if command -v kubectl >/dev/null 2>&1; then
  alias k='kubectl'
  alias kg='kubectl get'
  alias kd='kubectl describe'
  alias kdel='kubectl delete'
  alias kl='kubectl logs'
  alias kex='kubectl exec -it'

  # Kubectl completion
  source <(kubectl completion zsh 2>/dev/null) || true
fi

# -----------------------------------------------------------------------------
# Prompt Configuration
# -----------------------------------------------------------------------------
# Modern, informative prompt with git integration
PROMPT='%F{blue}╭─%f %F{green}%n%f%F{white}@%f%F{cyan}%m%f %F{yellow}%~%f${vcs_info_msg_0_}
%F{blue}╰─%f%(?..%F{red})❯%f '

# Right prompt with time and command execution time
RPROMPT='%F{242}%*%f'

# Show execution time for long-running commands
zmodload zsh/datetime

function preexec() {
  __TIMER=$EPOCHREALTIME
}

function precmd() {
  if [[ -n $__TIMER ]]; then
    local elapsed=$(( EPOCHREALTIME - __TIMER ))
    if (( elapsed > 3 )); then
      printf '\n%s took %s\n' "$1" "$(printf '%.2fs' $elapsed)"
    fi
    unset __TIMER
  fi
}

# -----------------------------------------------------------------------------
# Performance Optimizations
# -----------------------------------------------------------------------------
# Disable sharing history between terminals for better performance (optional)
# unsetopt share_history

# Skip global compinit for faster startup
skip_global_compinit=1

# -----------------------------------------------------------------------------
# Environment-specific Settings
# -----------------------------------------------------------------------------
# Source local configuration if exists
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# -----------------------------------------------------------------------------
# Welcome Message (Optional - comment out if not desired)
# -----------------------------------------------------------------------------
# Display system info on new terminal
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
elif command -v neofetch >/dev/null 2>&1; then
  neofetch --config none --disable packages --color_blocks off
fi

# =============================================================================
# End of Standalone ZSH Configuration
# =============================================================================
