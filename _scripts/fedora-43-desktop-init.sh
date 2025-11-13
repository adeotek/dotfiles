#!/bin/bash

##
# Fedora 43 environment installation and setup script
##

# Global system variables
CURRENT_OS_ID="$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)"
CURRENT_OS_VER="$(sed -n 's/^VERSION_ID=\(.*\)/\1/p' /etc/os-release)"

# Set Grub 2 save default
if ! grep -q 'GRUB_SAVEDEFAULT=' /etc/default/grub; then
    echo 'GRUB_SAVEDEFAULT="true"' | sudo tee -a /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    # Reboot !!!
fi

# Fedora specific tweaks

## DNF tweaks
(echo "max_parallel_downloads=10"; echo "fastestmirror=True") | sudo tee -a /etc/dnf/dnf.conf

## Update the system
sudo dnf upgrade -y

## Enable RPM Fusion repo
sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

## Enable Terra Sources
sudo dnf install -y --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release

## Update the system
sudo dnf upgrade -y --refresh
sudo dnf groupupdate core -y

## Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

## Install DNF 5
sudo dnf install dnf5 dnf5-plugins

## Add FlatHub repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

## Disable suspend when on AC
sudo -u gdm dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
## Disable sleep/suspend/hibernation/hybrid-sleep
sudo systemctl mask sleep.target suspend.target hybrid-sleep.target
## Enable sleep/suspend/hibernation/hybrid-sleep
#sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
## Change lid behavior
#sudo nano /etc/systemd/logind.conf

## Enable PWA in Flatpak
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons
# flatpak override --user --filesystem=~/.local/share/applications:create --filesystem=~/.local/share/icons:create com.google.Chrome
flatpak override --user --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.google.Chrome

## Set DNS resolver
### Option 1
# sudo mkdir -p /etc/systemd/resolved.conf.d
# sudo tee /etc/systemd/resolved.conf.d/00-custom.conf << EOF > /dev/null
# [Resolve]
# DNS=192.168.189.51
# FallbackDNS=192.168.189.52
# DNSSEC=false
# DNSOverTLS=true
# EOF
# sudo systemctl restart systemd-resolved.service
## If resolverctl doesn't work as expected, try running: "sudo fixfiles onboot"" and reboot
### Option 2
sudo bash -c 'mkdir -p /etc/systemd/system-preset && echo "disable systemd-resolved.service" >/etc/systemd/system-preset/20-systemd-resolved-disable.preset'
sudo systemctl --now mask systemd-resolved
sudo rm -rf /etc/resolv.conf
sudo tee /etc/resolv.conf << EOF > /dev/null
# Custom DNS resolve conf
nameserver 192.168.189.51
nameserver 192.168.189.52
options edns0 trust-ad
search .
EOF


# Install Nvidia drivers
sudo dnf install -y gcc kernel-headers kernel-devel kmodtool akmods mokutil openssl
## If SECURE BOOT is enable
#sudo kmodgenca -a
#sudo mokutil --import /etc/pki/akmods/certs/public_key.der # password: secure-boot
## Reboot and enroll MOK key !!!
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver # rhel/centos users can use kmod-nvidia instead
## Please remember to wait after the RPM transaction ends, until the kmod get built. This can take up to 5 minutes on some systems.
## Once the module is built, "modinfo -F version nvidia" should outputs the version of the driver such as 555.58.02 and not modinfo: ERROR: Module nvidia not found.
## Recheck, that modules built:
#sudo akmods --force
## Recheck boot image update:
#sudo dracut --force
## Reboot !!!

# Install tools
sudo dnf install -y curl wget mc nc nano git whois tree bash-completion netcat
sudo dnf install -y hstr jq tldr fzf ripgrep bat htop zoxide yazi
sudo dnf install -y grub-customizer neofetch gnome-tweaks inxi
# Laptops only
sudo dnf install -y tlp tlp-rdw

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
sudo yum groupinstall 'Development Tools'
brew install gcc

# Setup Python 3
sudo dnf install -y python3 python3-pip pipx sshpass
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  (echo; echo 'export PATH=$PATH:~/.local/bin') >> ~/.bashrc
fi

# Install Go
sudo dnf install -y golang
mkdir -p $HOME/go
echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
source $HOME/.bashrc

# bash profile config
if ! grep -q "export LC_ALL='C.UTF-8'" ~/.bashrc; then
  hstr --show-configuration >> ~/.bashrc
  tee -a ~/.bashrc <<EOF
export LC_ALL='C.UTF-8'
export EDITOR=nano
alias ll='ls -lAF'
EOF
  (echo; echo '# zoxide'; echo 'eval "$(zoxide init bash)"') >> ~/.bashrc
fi

# Copy git configuration from host
rm ~/.gitconfig
wget https://gist.githubusercontent.com/adeotek/66dede2bcd959d9cf93882559e3bd8da/raw/.gitconfig -O ~/.gitconfig
git config --global http.sslBackend gnutls

# Add GitHub & Azure DevOps SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi

# Install and configure tmux
sudo dnf install -y tmux
mkdir -p ~/.config/tmux
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/.tmux.conf -O ~/.config/tmux/tmux.conf
wget https://gist.githubusercontent.com/adeotek/30a0ab94b2b74a3a7f0fa60470699f9c/raw/gbs.tmux.conf.local -O ~/.config/tmux/tmux.conf.local

# Install Tabby Terminal
##curl -s https://packagecloud.io/install/repositories/eugeny/tabby/script.rpm.sh | sudo bash
wget https://github.com/Eugeny/tabby/releases/download/v1.0.211/tabby-1.0.211-linux-x64.rpm
sudo dnf install -y tabby-1.0.211-linux-x64.rpm
rm tabby-1.0.211-linux-x64.rpm

# Install Zed editor
sudo dnf update -y
sudo dnf install -y zed

# Install NodeJs
brew install node@20
echo 'export PATH="/home/linuxbrew/.linuxbrew/opt/node@20/bin:$PATH"' >> /home/$USER/.bash_profile
source $HOME/.bash_profile
npm install -g npm

# Install .NET SDK
sudo dnf install -y dotnet-sdk-8.0

# Install PowerShell Core
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo dnf makecache
sudo dnf install -y powershell

# Install and configure NeoVim
sudo dnf install -y luarocks neovim python3-neovim
sudo npm install -g neovim
sudo npm install -g tree-sitter-cli
mkdir -p ~/.config
git clone https://github.com/adeotek/neovim-adeotek.git ~/.config/nvim
if ! grep -q 'alias vim="nvim"' ~/.bashrc; then
  (echo; echo 'alias vim="nvim"') >> ~/.bashrc
fi

# Oh My Posh ???
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh)"

# Install JetBrains Toolbox
set -e
set -o pipefail
sudo dnf install -y jq fuse fuse-libs
curl -sL \
    $(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' \
        | jq -r '.TBA[0].downloads.linux.link') \
        | tar xzvf - \
            --directory="${HOME}/.local/bin" \
            --wildcards */jetbrains-toolbox \
            --strip-components=1
sudo wget https://icons.iconarchive.com/icons/papirus-team/papirus-apps/512/jetbrains-toolbox-icon.png -o /usr/share/applications/jetbrains-toolbox-icon.png
sudo tee /usr/share/applications/jetbrains-toolbox.desktop <<EOF
[Desktop Entry]
Type=Application
Name=JetBrains Toolbox
Exec=${HOME}/.local/bin/jetbrains-toolbox
Icon=/usr/share/applications/jetbrains-toolbox-icon.png
EOF

# Enable RDP with SELinux
tee /tmp/grd.te << EOF > /dev/null
module grd 1.0;
require {
    type system_dbusd_t;
    type unconfined_service_t;
    type xdm_t;
    class tcp_socket { getattr getopt read setopt shutdown write };
}
allow system_dbusd_t unconfined_service_t:tcp_socket { read write };
allow xdm_t unconfined_service_t:tcp_socket { getattr getopt read setopt shutdown write };
EOF
checkmodule -M -m -o /tmp/grd.mod /tmp/grd.te
semodule_package -o /tmp/grd.pp -m /tmp/grd.mod
sudo semodule -i /tmp/grd.pp

# Configure HL-NAS shares
smb_usr="ben"
read -s -p "Enter NAS password for user [$nas_user]: " smb_pwd
sudo dnf install -y samba-client cifs-utils
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
if [ ! -f /etc/pki/ca-trust/source/anchors/hlca.crt ]; then
  sudo mkdir -p /etc/pki/ca-trust/source/anchors
  sudo cp /mnt/hl-nas/storage/_Backup_/security/homelab-ssl/ca.pem /etc/pki/ca-trust/source/anchors/hlca.crt
  sudo openssl x509 -in /etc/pki/ca-trust/source/anchors/hlca.crt -out /etc/pki/ca-trust/source/anchors/hlca.pem -outform PEM
  sudo chmod 644 /etc/pki/ca-trust/source/anchors/hlca.pem
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
