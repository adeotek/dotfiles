#!/bin/bash

###
# Arch Linux post-install setup
###

# Update system
sudo pacman -Suy --noconfirm

# Install drivers and codecs
## Bluetooth
sudo pacman -S --noconfirm --needed bluez bluez-utils
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Install tools
## Base tools
sudo pacman -S --noconfirm --needed curl wget git
# ## GUI tools
# sudo pacman -S --noconfirm --needed grub-customizer gnome-tweaks
# Laptops only
sudo pacman -S --noconfirm --needed tlp tlp-rdw inxi

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
flatpak install -y dev.zed.Zed

# Clone and run dotfile setup
git clone https://github.com/adeotek/dotfiles.git ~/.dotfiles
chmod +x ~/.dotfiles/setup.sh
bash ~/.dotfiles/setup.sh

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
