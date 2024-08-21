#!/bin/bash

##
# WSL DEV environment installation and setup script
##

# Configuration variables
TIMEZONE="Europe/Bucharest"
WINDOWS_USER="georg"
CUSTOM_CA_PATH=""

if [ -z "$TIMEZONE" ]; then
  read -p "Enter your local timezone: " TIMEZONE
fi
if [ -z "$WINDOWS_USER" ]; then
  read -p "Enter your Windows username: " WINDOWS_USER
fi

# Global system variables
CURRENT_OS_ID="$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(sed -n 's/^VERSION_ID="\(.*\)"/\1/p' /etc/os-release)"

# Update
sudo apt update && sudo apt upgrade -y

# Set timezone
sudo apt install -yq tzdata && \
    sudo ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    sudo dpkg-reconfigure -f noninteractive tzdata

# Enable systemd
if [ ! -f /etc/wsl.conf ]; then
  sudo tee -a /etc/wsl.conf <<EOF
[boot]
systemd=true
[user]
default=$USER
EOF
fi

# Install custom CA certificates
if [ -z "$CUSTOM_CA_PATH" ]; then
  read -p "Enter WSL path to custom Root CA certificates: " CUSTOM_CA_PATH
fi
if [ -z "$CUSTOM_CA_PATH" ]; then
  echo "No custom CA certificates provided. Skipping..."
else
  sudo mkdir /usr/local/share/ca-certificates/extra
  sudo cp $CUSTOM_CA_PATH/* /usr/local/share/ca-certificates/extra/
  if [ -f /usr/local/share/ca-certificates/extra/zscaler_root_ca.cer ]; then
    sudo openssl x509 -inform DER -in /usr/local/share/ca-certificates/extra/zscaler_root_ca.cer -out /usr/local/share/ca-certificates/extra/zscaler_root_ca.crt
  fi
  sudo update-ca-certificates
fi

# Install distro tools
sudo apt install -y software-properties-common apt-transport-https build-essential
## Linux base tools
sudo apt install -y curl wget mc netcat-traditional nano git whois
## CLI tools
sudo apt install -y jq fd-find ripgrep fzf tldr bat tree htop zoxide bash-completion neofetch zsh
ln -s $(which fdfind) ~/.local/bin/fd
## Distro specific
sudo apt install -y libffi-dev libssl-dev
#sudo apt install -y hstr

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew install gcc

# Install Yazi
brew install yazi ffmpegthumbnailer sevenzip poppler imagemagick

sudo apt install -y python3 python3-pip python3-venv pipx sshpass
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
fi
# python3 -m pip install --upgrade pip

# Copy SSH key from host and set permissions
mkdir ~/.ssh
rm ~/.ssh/id_rsa
cp /mnt/c/Users/$WINDOWS_USER/.ssh/id_rsa ~/.ssh/id_rsa
rm ~/.ssh/id_rsa.pub
cp /mnt/c/Users/$WINDOWS_USER/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa.pub

# bash profile config
if ! grep -q "export LC_ALL='C.UTF-8'" ~/.bashrc; then
  hstr --show-configuration >> ~/.bashrc
  tee -a ~/.bashrc <<EOF
export LC_ALL='C.UTF-8'
export EDITOR=nano

EOF
  echo '# zoxide' >> ~/.bashrc
  echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
fi

# Copy git configuration from host
rm ~/.gitconfig
wget https://gist.githubusercontent.com/adeotek/66dede2bcd959d9cf93882559e3bd8da/raw/.gitconfig -O ~/.gitconfig
git config --global http.sslBackend gnutls

# Add GitHub & Azure DevOps SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi

# Install Ansible
sudo apt install -y ansible
#ansible-galaxy collection install community.general
#ansible-galaxy collection install community.docker
#ansible-galaxy install badpacketsllc.aws_cli
pipx ensurepath
pipx install ansible-lint

# Install .NET SDK and Tools
wget https://packages.microsoft.com/config/$CURRENT_OS_ID/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update && sudo apt upgrade -y
sudo apt install -y dotnet-sdk-8.0
dotnet tool install -g Adeotek.DevOpsTools

# Install NodeJs
#sudo apt install -y nodejs
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs
sudo npm install -g --upgrade npm

# Install Docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
$ sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Optional

## Install Go
#sudo apt install -y golang-go

### Install Rust
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Oh My Posh
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh)"

# Install Neovim
sudo apt install -y build-essential
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz
if ! grep -q 'export PATH="$PATH:/opt/nvim-linux64/bin"' ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
  echo 'alias vim="nvim"' >> ~/.bashrc
fi
sudo npm install -g neovim
sudo npm install -g tree-sitter-cli
mkdir ~/.config
git clone https://github.com/adeotek/neovim-adeotek.git ~/.config/nvim

# Configure tmux
sudo apt install -y tmux
mkdir -p ~/.config/tmux
### Option 1 (GBS single file config)
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/.tmux.conf -O ~/.config/tmux/tmux.conf
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/gbs.tmux.conf.local -O ~/.config/tmux/tmux.conf.local
### Option 2 (oh-my-tmux + GBS local config)
# git clone https://github.com/gpakosz/.tmux.git ~/.config/oh-my-tmux
# ln -s ~/.config/oh-my-tmux/.tmux.conf ~/.config/tmux/tmux.conf
# cp ~/.config/oh-my-tmux/.tmux.conf.local ~/.config/tmux/tmux.conf.local
