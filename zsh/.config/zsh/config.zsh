# ZSH configuration file

# # --- ZLE WIDGETS FOR SELECTION ---
# # Function to clear the mark (end selection)
# zsh_clear-mark() {
#     # If the region is active (REGION_ACTIVE is set to 1),
#     # calling set-mark-command without arguments unsets the mark.
#     if [[ $REGION_ACTIVE -eq 1 ]]; then
#         zle set-mark-command
#     fi
# }

# # 1. Custom Left Arrow (Backward Char)
# function zsh_move-backward-char() {
#     zsh_clear-mark
#     zle backward-char
# }
# zle -N zsh_move-backward-char

# # 2. Custom Right Arrow (Forward Char)
# function zsh_move-forward-char() {
#     zsh_clear-mark
#     zle forward-char
# }
# zle -N zsh_move-forward-char

# # 3. Custom Home (Beginning of Line)
# function zsh_move-beginning-of-line() {
#     zsh_clear-mark
#     zle beginning-of-line
# }
# zle -N zsh_move-beginning-of-line

# # 4. Custom End (End of Line)
# function zsh_move-end-of-line() {
#     zsh_clear-mark
#     zle end-of-line
# }
# zle -N zsh_move-end-of-line

# # Function to activate selection before moving
# zsh_start-selection() {
#     # Only set the mark if the region is NOT already active.
#     # This ensures repeated keystrokes just extend the selection.
#     if [[ $REGION_ACTIVE -ne 1 ]]; then
#         zle set-mark-command
#     fi
# }

# # --- Custom Widgets (Select + Move) ---
# # 1. Select Word Left
# function zsh_select-word-left() {
#     zsh_start-selection
#     zle backward-word
# }
# zle -N zsh_select-word-left

# # 2. Select Word Right
# function zsh_select-word-right() {
#     zsh_start-selection
#     zle forward-word
# }
# zle -N zsh_select-word-right

# # 3. Select to Beginning of Line
# function zsh_select-to-bol() {
#     zsh_start-selection
#     zle beginning-of-line
# }
# zle -N zsh_select-to-bol

# # 4. Select to End of Line
# function zsh_select-to-eol() {
#     zsh_start-selection
#     zle end-of-line
# }
# zle -N zsh_select-to-eol
# # --- END ZLE WIDGETS FOR SELECTION ---

# # create a zkbd compatible hash;
# # to add other keys to this hash, see: man 5 terminfo
# typeset -g -A key

# key[Home]="${terminfo[khome]}"
# key[End]="${terminfo[kend]}"
# key[Insert]="${terminfo[kich1]}"
# key[Backspace]="${terminfo[kbs]}"
# key[Delete]="${terminfo[kdch1]}"
# key[Up]="${terminfo[kcuu1]}"
# key[Down]="${terminfo[kcud1]}"
# key[Left]="${terminfo[kcub1]}"
# key[Right]="${terminfo[kcuf1]}"
# key[PageUp]="${terminfo[kpp]}"
# key[PageDown]="${terminfo[knp]}"
# key[Shift-Tab]="${terminfo[kcbt]}"
# key[Ctrl-Left]="${terminfo[kLFT5]}"
# key[Ctrl-Right]="${terminfo[kRIT5]}"
# key[Ctrl-Shift-Left]="${terminfo[kLFT6]}"
# key[Ctrl-Shift-Right]="${terminfo[kRIT6]}"
# key[Ctrl-Shift-Home]="${terminfo[kHOM6]}"
# key[Ctrl-Shift-End]="${terminfo[kEND6]}"

# # setup key accordingly
# # [[ -n "${key[Home]}"       ]] && bindkey -- "${key[Home]}"       beginning-of-line
# # [[ -n "${key[End]}"        ]] && bindkey -- "${key[End]}"        end-of-line
# [[ -n "${key[Home]}"       ]] && bindkey -- "${key[Home]}"       zsh_move-beginning-of-line
# [[ -n "${key[End]}"        ]] && bindkey -- "${key[End]}"        zsh_move-end-of-line
# [[ -n "${key[Insert]}"     ]] && bindkey -- "${key[Insert]}"     overwrite-mode
# [[ -n "${key[Backspace]}"  ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
# [[ -n "${key[Delete]}"     ]] && bindkey -- "${key[Delete]}"     delete-char
# [[ -n "${key[Up]}"         ]] && bindkey -- "${key[Up]}"         up-line-or-history
# [[ -n "${key[Down]}"       ]] && bindkey -- "${key[Down]}"       down-line-or-history
# # [[ -n "${key[Left]}"       ]] && bindkey -- "${key[Left]}"       backward-char
# # [[ -n "${key[Right]}"      ]] && bindkey -- "${key[Right]}"      forward-char
# [[ -n "${key[Left]}"       ]] && bindkey -- "${key[Left]}"       zsh_move-backward-char
# [[ -n "${key[Right]}"      ]] && bindkey -- "${key[Right]}"      zsh_move-forward-char
# [[ -n "${key[PageUp]}"     ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
# [[ -n "${key[PageDown]}"   ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
# [[ -n "${key[Shift-Tab]}"  ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
# [[ -n "${key[Ctrl-Left]}"  ]] && bindkey -- "${key[Ctrl-Left]}"  backward-word
# [[ -n "${key[Ctrl-Right]}" ]] && bindkey -- "${key[Ctrl-Right]}" forward-word
# [[ -n "${key[Ctrl-Shift-Left]}"  ]] && bindkey -- "${key[Ctrl-Shift-Left]}"  zsh_select-word-left
# [[ -n "${key[Ctrl-Shift-Right]}" ]] && bindkey -- "${key[Ctrl-Shift-Right]}" zsh_select-word-right
# [[ -n "${key[Ctrl-Shift-Home]}"  ]] && bindkey -- "${key[Ctrl-Shift-Home]}"  zsh_select-to-bol
# [[ -n "${key[Ctrl-Shift-End]}"   ]] && bindkey -- "${key[Ctrl-Shift-End]}"   zsh_select-to-eol

# # Finally, make sure the terminal is in application mode, when zle is
# # active. Only then are the values from $terminfo valid.
# if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
# 	autoload -Uz add-zle-hook-widget
# 	function zle_application_mode_start { echoti smkx }
# 	function zle_application_mode_stop { echoti rmkx }
# 	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
# 	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
# fi

export LC_ALL='C.UTF-8'
export EDITOR="nano"

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_SAVE_NO_DUPS # Don't save duplicate commands
setopt INC_APPEND_HISTORY # Save history as soon as it's entered

# Initialize Zsh Completion System
autoload -U compinit
compinit

# Global alias
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'
# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'


export PATH=$PATH:$HOME/.local/bin

# zsh-syntax-highlighting
# Try multiple common locations for plugins
if [ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source $HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [ -f "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source $HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  # NodeJs
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@22/bin" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/node@22/bin:$PATH"
  fi
  if [ -d "/home/linuxbrew/.linuxbrew/opt/node@24/bin" ]; then
    export PATH="/home/linuxbrew/.linuxbrew/opt/node@24/bin:$PATH"
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
alias service='sudo systemctl'
alias d='docker'
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

# hstr configuration
if $(command -v hstr >/dev/null 2>&1); then
    # HSTR configuration - add this to ~/.zshrc
    alias hh=hstr                    # hh to be alias for hstr
    setopt histignorespace           # skip cmds w/ leading space from history
    export HSTR_CONFIG=hicolor       # get more colors
    hstr_no_tiocsti() {
        zle -I
        { HSTR_OUT="$( { </dev/tty hstr ${BUFFER}; } 2>&1 1>&3 3>&- )"; } 3>&1;
        BUFFER="${HSTR_OUT}"
        CURSOR=${#BUFFER}
        zle redisplay
    }
    zle -N hstr_no_tiocsti
    bindkey '\C-r' hstr_no_tiocsti
    export HSTR_TIOCSTI=n
fi

# FZF key bindings (CTRL R for fuzzy history finder)
# Setup fzf
if [[ -d "$HOME/.fzf/bin" && ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi
if [[ -x "$(command -v fzf)" ]]; then
  source <(fzf --zsh)
  alias searchf='fzf --preview "bat --color=always --style=header,grid --line-range :500 {}"'
  alias dpsfzf='docker ps -a | fzf --preview "docker inspect {1}"'
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

# Cloud CLI tools
if $(command -v gcloud >/dev/null 2>&1); then
  # gcloud
  alias gc="gcloud"
  alias gcl="gcloud"
  # export CLOUDSDK_PYTHON_SITEPACKAGES=1
  # export CLOUDSDK_ACTIVE_CONFIG_NAME=default
  # export CLOUDSDK_CORE_DISABLE_PROMPTS=1
  # export CLOUDSDK_CORE_LOGGING_LEVEL=info
fi
if $(command -v terraform >/dev/null 2>&1); then
  # terraform
  alias tf="terraform"
  alias tfa='terraform apply'
  alias tff='terraform fmt'
  alias tfp='terraform plan'
fi

# Oh My Posh zsh config
if $(command -v oh-my-posh >/dev/null 2>&1); then
  eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/gbs.omp.yaml)"
fi

# Starship
# if $(command -v starship >/dev/null 2>&1); then
#   eval "$(starship init zsh)"
# fi

# zoxide
if $(command -v zoxide >/dev/null 2>&1); then
  eval "$(zoxide init zsh)"
fi
