## Init
if [[ -d "${0%/*}" ]]; then
  DIR=${0%/*}
else
  DIR="$PWD";
fi

# Check archlinux plugin commands here
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/archlinux

# Oh My Zsh (optional)
#source $DIR/plugins/oh-my-zsh.zsh

# Starship
#source $DIR/plugins/starship.zsh

# FZF key bindings (CTRL R for fuzzy history finder)
#source <(fzf --zsh)

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
