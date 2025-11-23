#!/bin/bash
##
# Fedora 43 environment installation script
##

# Fedora specific tweaks

## DNF tweaks
(echo "max_parallel_downloads=10"; echo "fastestmirror=True") | sudo tee -a /etc/dnf/dnf.conf

# ## Enable RPM Fusion repo
# sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
# sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# ## Enable Terra Sources
# sudo dnf install -y --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release

## Update the system
sudo dnf upgrade -y --refresh

## Firmware updates
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update

## Install DNF 5
sudo dnf install dnf5 dnf5-plugins

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
# sudo bash -c 'mkdir -p /etc/systemd/system-preset && echo "disable systemd-resolved.service" >/etc/systemd/system-preset/20-systemd-resolved-disable.preset'
# sudo systemctl --now mask systemd-resolved
# sudo rm -rf /etc/resolv.conf
# sudo tee /etc/resolv.conf << EOF > /dev/null
# # Custom DNS resolve conf
# nameserver 192.168.189.51
# nameserver 192.168.189.52
# options edns0 trust-ad
# search .
# EOF

# # Install Nvidia drivers
# sudo dnf install -y gcc kernel-headers kernel-devel kmodtool akmods mokutil openssl
# ## If SECURE BOOT is enable
# #sudo kmodgenca -a
# #sudo mokutil --import /etc/pki/akmods/certs/public_key.der # password: secure-boot
# ## Reboot and enroll MOK key !!!
# sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda libva-nvidia-driver # rhel/centos users can use kmod-nvidia instead
# ## Please remember to wait after the RPM transaction ends, until the kmod get built. This can take up to 5 minutes on some systems.
# ## Once the module is built, "modinfo -F version nvidia" should outputs the version of the driver such as 555.58.02 and not modinfo: ERROR: Module nvidia not found.
# ## Recheck, that modules built:
# #sudo akmods --force
# ## Recheck boot image update:
# #sudo dracut --force
# ## Reboot !!!

# # Enable RDP with SELinux
# tee /tmp/grd.te << EOF > /dev/null
# module grd 1.0;
# require {
#     type system_dbusd_t;
#     type unconfined_service_t;
#     type xdm_t;
#     class tcp_socket { getattr getopt read setopt shutdown write };
# }
# allow system_dbusd_t unconfined_service_t:tcp_socket { read write };
# allow xdm_t unconfined_service_t:tcp_socket { getattr getopt read setopt shutdown write };
# EOF
# checkmodule -M -m -o /tmp/grd.mod /tmp/grd.te
# semodule_package -o /tmp/grd.pp -m /tmp/grd.mod
# sudo semodule -i /tmp/grd.pp
