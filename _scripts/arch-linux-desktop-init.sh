#!/bin/bash

###
# Arch Linux post-install setup
###

# Update system
sudo pacman -Suy --noconfirm

# Install base tools
sudo pacman -S --noconfirm --needed base-devel git curl wget less

# Flatpak config
read -p "Do you want to configure flatpak? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  ## Add FlatHub repo
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  ## Enable PWA in Flatpak
  mkdir -p ~/.local/share/applications
  mkdir -p ~/.local/share/icons
  # flatpak override --user --filesystem=~/.local/share/applications:create --filesystem=~/.local/share/icons:create com.google.Chrome
  flatpak override --user --filesystem=~/.local/share/applications --filesystem=~/.local/share/icons com.google.Chrome
fi

# Install main GUI Apps
read -p "Do you want to install Google Chrome from flatpak? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  flatpak install -y com.google.Chrome
fi
read -p "Do you want to install VS Code from AUR? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  #flatpak install -y com.visualstudio.code
  yay -S --noconfirm --needed visual-studio-code-bin
fi
read -p "Do you want to install Yubico Authenticator from AUR? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  #sudo pacman -S --noconfirm --needed pcsclite ccid
  #sudo systemctl enable --now pcscd.service
  yay -S --noconfirm --needed yubico-authenticator-bin
fi
read -p "Do you want to install Gnome Extensions Manager from flatpak? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed fuse
  flatpak install -y flathub com.mattjakeman.ExtensionManager
fi

# Install yay
if ! yay --version >/dev/null; then
  sudo git clone https://aur.archlinux.org/yay.git /opt/yay.git
  sudo chown -R $USER:$USER /opt/yay.git
  cd /opt/yay.git
  makepkg -si
  cd ~
fi

# Install snapshot software (snapper)
read -p "Do you want to install snapper and related tools? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed grub-btrfs snapper snap-pac # snapper-rollback???
  yay -S --noconfirm --needed snapper-gui btrfs-assistant
  sudo systemctl enable --now snapper-timeline.timer
  read -p "Do you want to configure snapper? [Y/n]: " pkg_install
  if [[ "$pkg_install" == "y" || "$pkg_install" == "y" || "$pkg_install" == "" ]]; then
    sudo snapper -c root create-config /
    sudo snapper -c home create-config /home
  fi
fi

# Install JaKooLit Arch-Hyprland
read -p "Do you want to install JaKooLit Arch-Hyprland? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  if [ ! -f ~/Arch-Hyprland/install.sh ]; then
    git clone --depth=1 https://github.com/JaKooLit/Arch-Hyprland.git ~/Arch-Hyprland
    chmod +x ~/Arch-Hyprland/install.sh
  fi
  cd ~/Arch-Hyprland
  ./install.sh
  cd ~
fi

# Install Bluetooth drivers
read -p "Do you want to install bluetooth drivers? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed bluez bluez-utils
  sudo systemctl enable bluetooth.service
  sudo systemctl start bluetooth.service
fi

# Install printer drivers
read -p "Do you want to install printer drivers? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed cups cups-pdf
  sudo systemctl enable --now cups.service
  sudo pacman -S --noconfirm --needed print-manager system-config-printer hplip
fi

# GUI tools
read -p "Do you want to install [grub-customizer]? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed grub-customizer
fi
read -p "Do you want to install [gnome-tweaks]? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed gnome-tweaks
fi
# Laptops only
read -p "Do you want to install the laptop specific tools? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  sudo pacman -S --noconfirm --needed tlp tlp-rdw inxi
fi

# Clone and run dotfile setup
read -p "Do you want to clone and set up AdeoTEK dotfiles? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  if [ ! -f ~/.dotfiles/setup.sh ]; then
    git clone https://github.com/adeotek/dotfiles.git ~/.dotfiles
    chmod +x ~/.dotfiles/setup.sh
  fi
  bash ~/.dotfiles/setup.sh
fi

# Configure HL-NAS shares
read -p "Do you want to configure HL-NAS? [y/N]: " pkg_install
if [[ "$pkg_install" == "y" || "$pkg_install" == "y" ]]; then
  smb_usr="ben"
  read -s -p "Enter NAS password for user [$smb_user]: " smb_pwd
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
  bak_source_base_path="/mnt/hl-nas/storage/_Backup_"
  if [ ! -f /etc/ca-certificates/trust-source/hlca.crt ]; then
    sudo mkdir -p /etc/ca-certificates/trust-source/anchors
    sudo cp $bak_source_base_path/security/homelab-ssl/ca.pem /etc/ca-certificates/trust-source/anchors/hlca.crt
    sudo chmod 644 /etc/ca-certificates/trust-source/anchors/hlca.crt
    sudo update-ca-trust
  fi
  if [ ! -f ~/.ssh/id_rsa ]; then
    mkdir -p ~/.ssh
    sudo cp $bak_source_base_path/security/ssh-keys/id_rsa ~/.ssh/id_rsa
    sudo cp $bak_source_base_path/security/ssh-keys/id_rsa.pub ~/.ssh/id_rsa.pub
    sudo chown $USER:$USER ~/.ssh/id_rsa
    sudo chmod 600 ~/.ssh/id_rsa
    sudo chown $USER:$USER ~/.ssh/id_rsa.pub
    sudo chmod 644 ~/.ssh/id_rsa.pub
  fi
  if [ ! -f ~/.ssh/id_rsa_hl ]; then
    mkdir -p ~/.ssh
    sudo cp $bak_source_base_path/security/ssh-keys/id_rsa_hl ~/.ssh/id_rsa_hl
    sudo cp $bak_source_base_path/security/ssh-keys/id_rsa_hl.pub ~/.ssh/id_rsa_hl.pub
    sudo chown $USER:$USER ~/.ssh/id_rsa_hl
    sudo chmod 600 ~/.ssh/id_rsa_hl
    sudo chown $USER:$USER ~/.ssh/id_rsa_hl.pub
    sudo chmod 644 ~/.ssh/id_rsa_hl.pub
  fi
fi

