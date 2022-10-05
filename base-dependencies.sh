#!/bin/bash

# Print commands and exit on errors
set -xe


apt-get update

KERNEL=$(uname -r)
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --no-install-recommends --fix-missing\
  autoconf \
  automake \
  bison \
  build-essential \
  ca-certificates \
  clang \
  cmake \
  cpp \
  curl \
  flex \
  g++ \
  git \
  iproute2 \
  libboost-dev \
  libboost-filesystem-dev \
  libboost-graph-dev \
  libboost-iostreams-dev \
  libboost-program-options-dev \
  libboost-system-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libelf-dev \
  libevent-dev \
  libffi-dev \
  libfl-dev \
  libgc-dev \
  libgflags-dev \
  libgmp-dev \
  libjudy-dev \
  libpcap-dev \
  libpython3-dev \
  libreadline-dev \
  libssl-dev \
  libtool \
  libtool-bin \
  linux-headers-$KERNEL\
  llvm \
  make \
  net-tools \
  pkg-config \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  tcpdump \
  unzip \
  valgrind \
  vim \
  wget \
  xterm


sudo apt-get purge -y python3-protobuf || echo "Failed to remove python3-protobuf, probably because there was no such package installed"
sudo pip3 install protobuf==3.6.1

sudo pip3 install scapy
sudo pip3 install ipaddr

sudo pip3 install pypcap

sudo pip3 install psutil crcmod
