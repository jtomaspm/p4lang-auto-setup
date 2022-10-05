#!/bin/bash

# Print commands and exit on errors
set -xe

export DEBIAN_FRONTEND=noninteractive


# Add repository with P4 packages
# https://build.opensuse.org/project/show/home:p4lang

echo "deb http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_20.04/ /" | sudo tee /etc/apt/sources.list.d/home:p4lang.list
wget -qO - "http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_20.04/Release.key" | apt-key add -

apt-get update -qq


apt-get -qq -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install  -y --no-install-recommends --fix-missing\
  curl \
  git \
  iproute2 \
  p4lang-p4c \
  p4lang-bmv2 \
  p4lang-pi

sudo pip3 install -U scapy ipaddr ptf psutil grpcio
