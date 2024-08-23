#!/bin/bash

###
# zsh install script
###

# Init
if [[ -z "$CDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    CDIR="${0%/*}"
  else
    CDIR="$PWD";
  fi
  source "$CDIR/_helpers.sh"
fi

# Install
install_package "zsh" "zsh --version"

# # Install oh-my-zsh
# ohmyzsh_dir="$HOME/.config/oh-my-zsh"
# ## Set zsh as default shell
# #chsh -s $(which zsh)
# ## Install oh-my-zsh from GitHub
# #sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# ## Manual install
# if [ ! -d "$ohmyzsh_dir" ]; then 
#   git clone https://github.com/ohmyzsh/ohmyzsh.git $ohmyzsh_dir
#   git clone https://github.com/zsh-users/zsh-autosuggestions $ohmyzsh_dir/custom/plugins/zsh-autosuggestions
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ohmyzsh_dir/custom/plugins/zsh-syntax-highlighting
# fi
