#!/bin/bash

###
# OctoPrint RaspberryPI Setup
###

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# OctoPrint install & setup
sudo apt install -y python3 python3-pip python3-dev python3-setuptools python3-venv git libyaml-dev build-essential libffi-dev libssl-dev
sudo usermod -a -G tty pi
sudo usermod -a -G dialout pi
if [ ! -f ~/octoprint/bin/activate ]; then
  python3 -m venv ~/octoprint
  source ~/octoprint/bin/activate
  pip install --upgrade pip wheel
  pip install octoprint
  deactivate
fi

## Create OctoPrint service
if [ ! -f /etc/systemd/system/octoprint.service ]; then
  sudo tee /etc/sudoers.d/octoprint-shutdown <<EOF
pi ALL=NOPASSWD: /sbin/shutdown
EOF
  sudo tee /etc/sudoers.d/octoprint-service <<EOF
pi ALL=NOPASSWD: /usr/sbin/service
EOF

  sudo tee /etc/systemd/system/octoprint.service <<EOF
[Unit]
Description=The snappy web interface for your 3D printer
After=network-online.target
Wants=network-online.target
[Service]
Environment="LC_ALL=C.UTF-8"
Environment="LANG=C.UTF-8"
Type=exec
User=pi
ExecStart=/home/pi/octoprint/bin/octoprint serve
[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable octoprint.service

  sudo reboot
fi

