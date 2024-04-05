#!/usr/bin/env bash

set -eux -o pipefail

SRC_DIR="./files/"
HOST_SRC_DIR="./hosts/$HOSTNAME/"

if [ ! -d $SRC_DIR ]; then
  echo "You need to clone the whole repository, not just download this script!"
  exit 1
fi

if [ ! -d $HOST_SRC_DIR ]; then
  echo "Your system hostname is set wrong!!"
  echo  "$HOSTNAME is not a PC that can be configured using this script!"
  exit 1
fi

# Install basic dependencies
sudo apt install kde-plasma-desktop firefox-esr mumble vlc ark pipewire-{pulse,jack,alsa} wget curl git ffmpeg libportaudio2

# Create users
sudo adduser ury --disabled-password
printf 'ury\nury\n' | sudo passwd ury
sudo usermod -aG dialout ury
sudo usermod -aG dialout computing

# Configure UMC outputs
sudo mkdir -p /etc/pipewire/pipewire.conf.d/
sudo cp "$HOST_SRC_DIR/20-umc-split.conf" /etc/pipewire/pipewire.conf.d/

# Install BAPS
sudo mkdir -p /opt/BAPS
sudo wget https://github.com/UniversityRadioYork/BAPSicle/releases/download/3.1.1/BAPSicle -O /opt/BAPS/BAPSicle
sudo chmod +x /opt/BAPS/BAPSicle
sudo cp "$SRC_DIR/bapsicle.service" /etc/systemd/user/
sudo systemctl daemon-reload
sudo systemctl --global enable bapsicle.service

# Install BAPS Presenter
wget https://github.com/UniversityRadioYork/NeutronStudio/releases/download/v0.0.1/neutron-studio_0.0.1_amd64.deb -O /tmp/baps-presenter.deb
sudo apt install /tmp/baps-presenter.deb

# Set up the network mounts
cat "$SRC_DIR/extra-fstab" | sudo tee -a /etc/fstab > /dev/null
