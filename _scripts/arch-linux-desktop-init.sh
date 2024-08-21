#!/bin/bash

# Update system
sudo pacman -Suy --noconfirm

# Install drivers and codecs
## Bluetooth
sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Install tools
## Linux base
sudo pacman -S --noconfirm --needed curl wget mc netcat nano vi git whois
## CLI tools
sudo pacman -S --noconfirm --needed jq fd ripgrep fzf yazi tldr bat tree htop zoxide bash-completion neofetch
## Yazi
sudo pacman -S --noconfirm --needed yazi ffmpegthumbnailer p7zip poppler imagemagick
## GUI tools
sudo pacman -S --noconfirm --needed grub-customizer gnome-tweaks
# Laptops only
sudo pacman -S --noconfirm --needed tlp tlp-rdw inxi

# bash profile config
if ! grep -q "export LC_ALL='C.UTF-8'" ~/.bashrc; then
  tee -a ~/.bashrc <<EOF
export LC_ALL='C.UTF-8'
export EDITOR=nano
alias ll='ls -lAF'
EOF
fi
## zoxide bash config
if ! grep -q "# zoxide" ~/.bashrc; then
  (echo; echo '# zoxide'; echo 'eval "$(zoxide init bash)"') >> ~/.bashrc
fi
## yazi config
mkdir -p ~/.config/yazi
if [ ! -f ~/.config/yazi/yazi.toml ]; then
    tee -a ~/.config/yazi/yazi.toml <<EOF
[manager]
show_hidden = true
EOF
fi
if ! grep -q "function yy() {" ~/.bashrc; then
  tee -a ~/.bashrc <<EOF
# yazi
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "\$@" --cwd-file="\$tmp"
	if cwd="\$(cat -- "\$tmp")" && [ -n "\$cwd" ] && [ "\$cwd" != "\$PWD" ]; then
		builtin cd -- "\$cwd"
	fi
	rm -f -- "\$tmp"
}
EOF
fi

## Add FlatHub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## Enable PWA in Flatpak
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons
# flatpak override --user --filesystem=~/.local/share/applications:create --filesystem=~/.local/share/icons:create com.google.Chrome
flatpak override --user --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.google.Chrome

# Install Flatpaks
flatpak install -y com.google.Chrome
flatpak install -y com.visualstudio.code
flatpak install -y dev.zed.Zed

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo pacman -S --noconfirm --needed base-devel
brew install gcc

# Install and configure OhMyPosh and CascadiaCode fonts
## Download fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip -O ~/CascadiaCode.zip
## Unpack fonts
mkdir -p ~/.local/share/fonts/CascadiaCode
unzip ~/CascadiaCode.zip -d ~/.local/share/fonts/CascadiaCode
rm ~/CascadiaCode.zip
## Configure fonts
fc-cache -fv
## Install oh-my-posh
curl -s https://ohmyposh.dev/install.sh | bash -s
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  (echo; echo 'export PATH=$PATH:~/.local/bin') >> ~/.bashrc
fi
## Download custom theme
mkdir -p ~/.config/oh-my-posh
wget https://gist.githubusercontent.com/adeotek/0cccb275b9a8acd909cdbef367baa8d5/raw/gbs.omp.yaml -O ~/.config/oh-my-posh/gbs.omp.yaml
# Add bash config in .bashrc
if ! grep -q '# Oh My Posh bash config' ~/.bashrc; then
  (echo; echo "# Oh My Posh bash config"; echo "eval \"\$(oh-my-posh --init --shell bash --config ~/.config/oh-my-posh/gbs.omp.yaml)\"") >> ~/.bashrc
fi

# Set git config
rm ~/.gitconfig
wget https://gist.githubusercontent.com/adeotek/66dede2bcd959d9cf93882559e3bd8da/raw/.gitconfig -O ~/.gitconfig
git config --global http.sslBackend gnutls

# Add GitHub & Azure DevOps SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi

# Configure Kitty
mkdir -p ~/.config/kitty
rm ~/.config/kitty/current-theme.conf
cp ./kitty-current-theme.conf ~/.config/kitty/current-theme.conf
if ! grep -q "include current-theme.conf" ~/.config/kitty/kitty.conf; then
  tee -a ~/.bashrc <<EOF
# BEGIN_KITTY_THEME
# Catppuccin-Mocha
include current-theme.conf
# END_KITTY_THEME
font_family      CaskaydiaCove Nerd Font Mono
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 14.0
EOF
fi

# Install and configure tmux
sudo pacman -S --noconfirm --needed tmux
mkdir -p ~/.config/tmux
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/.tmux.conf -O ~/.config/tmux/tmux.conf
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/gbs.tmux.conf.local -O ~/.config/tmux/tmux.conf.local

# Setup Python 3
sudo pacman -S --noconfirm --needed python python-pip python-pipx sshpass
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  (echo; echo 'export PATH=$PATH:~/.local/bin') >> ~/.bashrc
fi

# Install NodeJs
brew install node@20
echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/node@20/bin:$PATH"' >> /home/$USER/.bash_profile
source $HOME/.bash_profile
npm install -g npm

# Install and configure NeoVim
sudo pacman -R --noconfirm vim
sudo pacman -S --noconfirm --needed luarocks neovim python-neovim
npm install -g neovim
npm install -g tree-sitter-cli
mkdir -p ~/.config
git clone https://github.com/adeotek/neovim-adeotek.git ~/.config/nvim
if ! grep -q 'alias vim="nvim"' ~/.bashrc; then
  (echo; echo 'alias vim="nvim"') >> ~/.bashrc
fi

# Install Tabby Terminal
wget https://github.com/Eugeny/tabby/releases/download/v1.0.211/tabby-1.0.211-linux-x64.pacman
sudo pacman -U --noconfirm --needed tabby-1.0.211-linux-x64.pacman
rm tabby-1.0.211-linux-x64.pacman

# # Install Go
# sudo dnf install -y golang
# mkdir -p $HOME/go
# echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
# source $HOME/.bashrc

# # Install .NET SDK
# sudo dnf install -y dotnet-sdk-8.0

# # Install PowerShell Core
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
# sudo dnf makecache
# sudo dnf install -y powershell


# Configure HL-NAS shares
smb_usr="ben"
read -s -p "Enter NAS password for user [$nas_user]: " smb_pwd
sudo pacman -S --noconfirm --needed smbclient cifs-utils
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
if [ ! -f /etc/ca-certificates/trust-source/hlca.crt ]; then
  sudo mkdir -p /etc/ca-certificates/trust-source/anchors
  sudo cp /mnt/hl-nas/storage/_Backup_/security/homelab-ssl/ca.pem /etc/ca-certificates/trust-source/anchors/hlca.crt
  sudo chmod 644 /etc/ca-certificates/trust-source/anchors/hlca.crt
  sudo update-ca-trust
fi
if [ ! -f ~/.ssh/id_rsa ]; then
  mkdir -p ~/.ssh
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa ~/.ssh/id_rsa
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa.pub ~/.ssh/id_rsa.pub
  sudo chown $USER:$USER ~/.ssh/id_rsa
  sudo chmod 600 ~/.ssh/id_rsa
  sudo chown $USER:$USER ~/.ssh/id_rsa.pub
  sudo chmod 644 ~/.ssh/id_rsa.pub
fi
if [ ! -f ~/.ssh/id_rsa_hl ]; then
  mkdir -p ~/.ssh
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa_hl ~/.ssh/id_rsa_hl
  sudo cp /mnt/hl-nas/storage/_Backup_/security/ssh-keys/id_rsa_hl.pub ~/.ssh/id_rsa_hl.pub
  sudo chown $USER:$USER ~/.ssh/id_rsa_hl
  sudo chmod 600 ~/.ssh/id_rsa_hl
  sudo chown $USER:$USER ~/.ssh/id_rsa_hl.pub
  sudo chmod 644 ~/.ssh/id_rsa_hl.pub
fi
