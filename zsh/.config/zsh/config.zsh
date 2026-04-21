# ZSH configuration file

# --- Environment ---
export LC_ALL='C.UTF-8'
export EDITOR="nano"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- History ---
HISTFILE="${XDG_DATA_HOME}/zsh/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "${HISTFILE:h}"  # :h is ZSH's built-in dirname — no subshell fork

setopt EXTENDED_HISTORY       # Record timestamp with each history entry
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicates when a new entry is added
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to the history file
setopt HIST_IGNORE_SPACE      # Ignore commands prefixed with a space
setopt HIST_VERIFY            # Show expanded history before executing
setopt SHARE_HISTORY          # Share history across sessions (supersedes INC_APPEND_HISTORY)

# --- General shell options ---
setopt NO_FLOW_CONTROL  # Disable Ctrl+S / Ctrl+Q terminal flow control
setopt AUTO_CD          # Type a directory name to cd into it

# --- PATH ---
typeset -U path  # keep path entries unique
path=(
  $HOME/.local/bin
  $HOME/bin
  /usr/local/bin
  $path
)

# Add .tools to path if it exists
[[ -d "$HOME/.tools" ]] && path+=("$HOME/.tools")

# Homebrew — must come early so brew-installed tools (antidote, starship, zoxide) are findable
if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  for _node_ver in node@{24,22,20}; do
    if [[ -d "/home/linuxbrew/.linuxbrew/opt/${_node_ver}/bin" ]]; then
      path=("/home/linuxbrew/.linuxbrew/opt/${_node_ver}/bin" $path)
      break
    fi
  done
  unset _node_ver
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

# FZF standalone install
[[ -d "$HOME/.fzf/bin" ]] && path+=("$HOME/.fzf/bin")

# --- Plugin pre-configuration (must be set before antidote sources the plugins) ---

# zsh-autosuggestions: fall back to completions when history has no match
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20  # prevent lag on very long lines

# zsh-history-substring-search: highlight found / not-found matches
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=yellow,fg=black,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'

# --- Completion styles (must be set before compinit runs via belak/zsh-utils) ---
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to end of completed word
setopt AUTO_MENU           # Show completion menu on successive Tab
setopt AUTO_LIST           # List choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # Add trailing slash after completed directory

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/.zcompcache"

# --- Antidote plugin manager ---
# Detect antidote: prefer git-clone location, then Homebrew
_antidote_path="${ZDOTDIR:-$HOME}/.antidote/antidote.zsh"
if [[ ! -f "$_antidote_path" ]] && command -v brew >/dev/null 2>&1; then
  _antidote_path="$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh"
fi

if [[ -f "$_antidote_path" ]]; then
  source "$_antidote_path"

  # Static bundle file — regenerated automatically when plugins list changes
  _zsh_plugins_txt="${XDG_CONFIG_HOME}/zsh/zsh_plugins.txt"
  _zsh_plugins_zsh="${XDG_CACHE_HOME}/zsh/zsh_plugins.zsh"
  mkdir -p "${_zsh_plugins_zsh:h}"
  if [[ ! -f "$_zsh_plugins_zsh" || "$_zsh_plugins_txt" -nt "$_zsh_plugins_zsh" ]]; then
    antidote bundle < "$_zsh_plugins_txt" >| "$_zsh_plugins_zsh"
  fi
  source "$_zsh_plugins_zsh"
  unset _zsh_plugins_txt _zsh_plugins_zsh
fi
unset _antidote_path

# Fallback: if antidote/belak didn't call compinit, do it ourselves
if ! (( $+functions[compdef] )); then
  autoload -Uz compinit && compinit
fi

# --- Key bindings ---
bindkey -e  # Emacs-style editing

# history-substring-search — bind AFTER the plugin is loaded
bindkey "${terminfo[kcuu1]}" history-substring-search-up    # Up arrow (terminfo)
bindkey "${terminfo[kcud1]}" history-substring-search-down  # Down arrow (terminfo)
bindkey '^[[A' history-substring-search-up                  # Up arrow (fallback)
bindkey '^[[B' history-substring-search-down                # Down arrow (fallback)
bindkey '^P' history-substring-search-up                    # Ctrl+P
bindkey '^N' history-substring-search-down                  # Ctrl+N

# Word / line navigation
bindkey '^[[1;5C' forward-word       # Ctrl+Right
bindkey '^[[1;5D' backward-word      # Ctrl+Left
bindkey '^[[H'    beginning-of-line  # Home
bindkey '^[[F'    end-of-line        # End
bindkey '^[[3~'   delete-char        # Delete

# Accept autosuggestion with Ctrl+Space
bindkey '^ ' autosuggest-accept

# --- Aliases ---
# File listing — prefer eza when available
if command -v eza >/dev/null 2>&1; then
  alias ls='eza -a --icons'
  alias ll='eza -al --icons --git'
  alias lt='eza -a --tree --level=1 --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -lAhF'
fi
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias dud='du -h --max-depth=1 | sort -hr'
alias df='df -h'
alias free='free -h'
alias psmem='ps auxf | sort -nr -k 4 | head -5'
alias pscpu='ps auxf | sort -nr -k 3 | head -5'
alias service='sudo systemctl'

alias d='docker'
alias dc='docker compose'

# Package manager shorthand
if [[ -f /etc/os-release ]]; then
  case "$(awk -F= '/^ID=/ { gsub(/"/, "", $2); print $2 }' /etc/os-release)" in
    arch)              alias pacman='sudo pacman' ;;
    debian|ubuntu|pop) alias apt='sudo apt' ;;
    fedora|redhat)     alias dnf='sudo dnf' ;;
  esac
fi

# Neovim
if command -v nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
  export EDITOR='nvim'
fi

# Cloud / DevOps
if command -v gcloud >/dev/null 2>&1; then
  alias gc='gcloud'
fi
if command -v terraform >/dev/null 2>&1; then
  alias tf='terraform'
  alias tfa='terraform apply'
  alias tff='terraform fmt'
  alias tfp='terraform plan'
fi

# --- Yazi (cd-on-exit wrapper) ---
if command -v yazi >/dev/null 2>&1; then
  function yy() {
    local tmp
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# --- FZF ---
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

  if command -v bat >/dev/null 2>&1; then
    alias searchf='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  fi
fi

# --- Zoxide (smart cd) ---
if command -v zoxide >/dev/null 2>&1; then
  _zoxide_cache="${XDG_CACHE_HOME}/zsh/zoxide_init.zsh"
  if [[ ! -f "$_zoxide_cache" || "${commands[zoxide]}" -nt "$_zoxide_cache" ]]; then
    zoxide init zsh >| "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
  _starship_cache="${XDG_CACHE_HOME}/zsh/starship_init.zsh"
  if [[ ! -f "$_starship_cache" || "${commands[starship]}" -nt "$_starship_cache" ]]; then
    starship init zsh >| "$_starship_cache"
  fi
  source "$_starship_cache"
  unset _starship_cache
fi

# --- Local overrides ---
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
