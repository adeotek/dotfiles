#!/bin/bash

###
# zsh install script
###

# Init
if [[ -z "$BDIR" ]]; then
  if [[ -d "${0%/*}" ]]; then
    RDIR=$(dirname "${0%/*}")
  else
    RDIR=$(dirname "$PWD")
  fi
  CDIR="$RDIR/_scripts/core";
  source "$CDIR/_helpers.sh"
fi

# Install
install_package "zsh" "zsh --version"

# # Install oh-my-zsh
# ohmyzsh_dir="$CURRENT_CONFIG_DIR/oh-my-zsh"
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
