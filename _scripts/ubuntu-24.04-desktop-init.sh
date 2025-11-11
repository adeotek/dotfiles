#!/bin/bash

##
# Ubuntu 24.04 environment installation and setup script
##

# Global system variables
CURRENT_OS_ID="$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(sed -n 's/^VERSION_ID="\(.*\)"/\1/p' /etc/os-release)"
CURRENT_USER="$USER"

# Update
sudo apt-get update && sudo apt-get upgrade -y

# Install tools
sudo apt-get install -y software-properties-common apt-transport-https
sudo apt-get install -y curl wget netcat-traditional nano git mc whois bash-completion tree
sudo apt-get install -y hstr libffi-dev libssl-dev jq tmux tldr fzf ripgrep bat htop zoxide yazi

sudo apt-get install -y python3 python3-pip python3-venv pipx sshpass
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
fi

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

# Install .NET SDK and Tools
wget https://packages.microsoft.com/config/$CURRENT_OS_ID/$CURRENT_OS_VER/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y dotnet-sdk-8.0
dotnet tool install -g Adeotek.DevOpsTools

# Install NodeJs
#sudo apt-get install -y nodejs
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs
sudo npm install -g --upgrade npm

## Install Go
sudo apt-get install -y golang-go

# Oh My Posh
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh)"

# Install Neovim
sudo apt-get install -y build-essential luarocks
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
mkdir -p ~/.config/tmux
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/.tmux.conf -O ~/.config/tmux/tmux.conf
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/gbs.tmux.conf.local -O ~/.config/tmux/tmux.conf.local

# Install VS Code
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt-get update
sudo apt-get install code

# Install Tabby Terminal
curl -s https://packagecloud.io/install/repositories/eugeny/tabby/script.deb.sh | sudo bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$smb_usr/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo apt-get install build-essential
brew install gcc

# Install Grub Customizer
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt-get update
sudo apt-get install grub-customizer

# Install Yubico Authenticator
wget https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz
tar -xvf yubico-authenticator-latest-linux.tar.gz
rm yubico-authenticator-latest-linux.tar.gz
cd yubico-authenticator-7.0.0-linux/
sudo apt-get install -y pcscd
sudo systemctl daemon-reload
sudo systemctl enable --now pcscd
./desktop_integration.sh

# Configure SNB shares (script + permanent storage)
smb_usr="ben"
read -s -p "Enter NAS password for user [$nas_user]: " smb_pwd
sudo apt-get install -y cifs-utils
if ! grep -q "//hl-nas.local/storage" /etc/fstab; then
  sudo mkdir -p /mnt/hl-nas/storage
  echo "//hl-nas.local/storage /mnt/hl-nas/storage cifs nofail,rw,vers=3.0,username=$smb_usr,password=$smb_pwd,uid=1000 0 0" | sudo tee -a /etc/fstab
  sudo systemctl daemon-reload
  sudo mount /mnt/hl-nas/storage
fi

if [ ! -f /usr/bin/mount-hl-nas ]; then
  sudo tee /usr/bin/mount-hl-nas <<EOF
#!/bin/bash
if [ -z "\$1" ]; then
  echo "Usage: mount-hl-nas <share>"
  exit 1
fi
SMB_SERVER="hl-nas.local"
SMB_USER="$smb_usr"
SMB_PASSWD="$smb_pwd"
if [ ! -d /mnt/hl-nas/\$1 ]; then
  sudo mkdir -p /mnt/hl-nas/\$1
fi
sudo mount -t cifs -o username=\$SMB_USER,password=\$SMB_PASSWD //\$SMB_SERVER/\$1 /mnt/hl-nas/\$1
EOF
  sudo chmod +x /usr/bin/mount-hl-nas
fi

# Install custom CA and SSH keys
if [ ! -f /usr/local/share/ca-certificates/extra/ca.crt ]; then
  sudo mkdir /usr/local/share/ca-certificates/extra
  sudo cp /mnt/hl-nas/storage/_Backup_/security/homelab-ssl/ca.pem /usr/local/share/ca-certificates/extra/ca.crt
  sudo update-ca-certificates
fi
if [ ! -f ~/.ssh/id_rsa ]; then
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa ~/.ssh/id_rsa
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa.pub ~/.ssh/id_rsa.pub
  sudo chown $CURRENT_USER:$CURRENT_USER ~/.ssh/id_rsa
  sudo chmod 600 ~/.ssh/id_rsa
  sudo chown $CURRENT_USER:$CURRENT_USER ~/.ssh/id_rsa.pub
  sudo chmod 644 ~/.ssh/id_rsa.pub
fi
if [ ! -f ~/.ssh/id_rsa_hl ]; then
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa_hl ~/.ssh/id_rsa_hl
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa_hl.pub ~/.ssh/id_rsa_hl.pub
  sudo chown $CURRENT_USER:$CURRENT_USER ~/.ssh/id_rsa_hl
  sudo chmod 600 ~/.ssh/id_rsa_hl
  sudo chown $CURRENT_USER:$CURRENT_USER ~/.ssh/id_rsa_hl.pub
  sudo chmod 644 ~/.ssh/id_rsa_hl.pub
fi
