export ZSH="$HOME/.config/oh-my-zsh"

ZSH_THEME="fox"

plugins=(
  docker
  docker-compose
  git
  fzf
  sudo
  systemd
  tmux
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
)

case "$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)" in
  arch)
    plugins+=(archlinux)
    ;;
  debian)
    plugins+=(debian)
    ;;
  ubuntu)
    plugins+=(ubuntu)
    ;;
esac

source $ZSH/oh-my-zsh.sh
