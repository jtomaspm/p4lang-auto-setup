#!/bin/bash

# Print script commands and exit on errors.
set -xe

#Src
BMV2_COMMIT="f16d0de3486aa7fb2e1fe554aac7d237cc1adc33"  # 2022-May-01
PI_COMMIT="f547455a260b710706bef82afab4cb9937bac416"    # 2022-May-01
P4C_COMMIT="1471fdd22b683e1946b7730d83c877d94daba683"   # 2022-May-01
PTF_COMMIT="405513bcad2eae3092b0ac4ceb31e8dec5e32311"   # 2022-May-01
PROTOBUF_COMMIT="v3.6.1"
GRPC_COMMIT="tags/v1.17.2"

#Get the number of cores to speed up the compilation process
NUM_CORES=`grep -c ^processor /proc/cpuinfo`


# The install steps for p4lang/PI and p4lang/behavioral-model end
# up installing Python module code in the site-packages directory
# mentioned below in this function.  That is were GNU autoconf's
# 'configure' script seems to find as the place to put them.

# On Ubuntu systems when you run the versions of Python that are
# installed via Debian/Ubuntu packages, they only look in a
# sibling dist-packages directory, never the site-packages one.

# If I could find a way to change the part of the install script
# so that p4lang/PI and p4lang/behavioral-model install their
# Python modules in the dist-packages directory, that sounds
# useful, but I have not found a way.

# As a workaround, after finishing the part of the install script
# for those packages, I will invoke this function to move them all
# into the dist-packages directory.

# Some articles with questions and answers related to this.
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=765022
# https://bugs.launchpad.net/ubuntu/+source/automake/+bug/1250877
# https://unix.stackexchange.com/questions/351394/makefile-installing-python-module-out-of-of-pythonpath

# --- Mininet --- #
git clone https://github.com/mininet/mininet mininet
cd mininet
PATCH_DIR="${HOME}/patches"
patch -p1 < "${PATCH_DIR}/mininet-dont-install-python2-2022-apr.patch" || echo "Errors while attempting to patch mininet, but continuing anyway ..."
cd ..
# TBD: Try without installing openvswitch, i.e. no '-v' option, to see
# if everything still works well without it.
sudo ./mininet/util/install.sh -nw

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-7-after-mininet-install.txt



find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-1-before-protobuf.txt

# --- Protobuf --- #
git clone https://github.com/google/protobuf.git
cd protobuf
git checkout ${PROTOBUF_COMMIT}
./autogen.sh
# install-p4dev-v4.sh script doesn't have --prefix=/usr option here.
./configure --prefix=/usr
make -j${NUM_CORES}
sudo make install
sudo ldconfig
# Force install python module
#cd python
#sudo python3 setup.py install
#cd ../..
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-2-after-protobuf.txt

# --- gRPC --- #
git clone https://github.com/grpc/grpc.git
cd grpc
git checkout ${GRPC_COMMIT}
git submodule update --init --recursive
# Apply patch that seems to be necessary in order for grpc v1.17.2 to
# compile and install successfully on an Ubuntu 19.10 and later
# system.
PATCH_DIR="${HOME}/patches"
patch -p1 < "${PATCH_DIR}/disable-Wno-error-and-other-small-changes.diff" || echo "Errors while attempting to patch grpc, but continuing anyway ..."
make -j${NUM_CORES}
sudo make install
# I believe the following 2 commands, adapted from similar commands in
# src/python/grpcio/README.rst, should install the Python3 module
# grpc.
find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-2b-before-grpc-pip3.txt
pip3 list | tee $HOME/pip3-list-2b-before-grpc-pip3.txt
sudo pip3 install -rrequirements.txt
GRPC_PYTHON_BUILD_WITH_CYTHON=1 sudo pip3 install .
sudo ldconfig
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-3-after-grpc.txt

# Note: This is a noticeable difference between how an earlier
# user-bootstrap.sh version worked, where it effectively ran
# behavioral-model's install_deps.sh script, then installed PI, then
# went back and compiled the behavioral-model code.  Building PI code
# first, without first running behavioral-model's install_deps.sh
# script, might result in less PI project features being compiled into
# its binaries.

# --- PI/P4Runtime --- #
git clone https://github.com/p4lang/PI.git
cd PI
git checkout ${PI_COMMIT}
git submodule update --init --recursive
./autogen.sh
# install-p4dev-v4.sh adds more --without-* options to the configure
# script here.  I suppose without those, this script will cause
# building PI code to include more features?
./configure --with-proto
make -j${NUM_CORES}
sudo make install
# install-p4dev-v4.sh at this point does these things, which might be
# useful in this script, too:
# Save about 0.25G of storage by cleaning up PI build
make clean
sudo ldconfig
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-4-after-PI.txt

# --- Bmv2 --- #
git clone https://github.com/p4lang/behavioral-model.git
cd behavioral-model
git checkout ${BMV2_COMMIT}
./install_deps.sh
./autogen.sh
./configure --enable-debugger --with-pi --with-thrift
make -j${NUM_CORES}
sudo make install-strip
sudo ldconfig
# install-p4dev-v4.sh script does this here:
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-5-after-behavioral-model.txt

# --- P4C --- #
git clone https://github.com/p4lang/p4c
cd p4c
git checkout ${P4C_COMMIT}
git submodule update --init --recursive
mkdir -p build
cd build
cmake ..
# The command 'make -j${NUM_CORES}' works fine for the others, but
# with 2 GB of RAM for the VM, there are parts of the p4c build where
# running 2 simultaneous C++ compiler runs requires more than that
# much memory.  Things work better by running at most one C++ compilation
# process at a time.
make -j1
sudo make install
sudo ldconfig
cd ../..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-6-after-p4c.txt

# --- PTF --- #
git clone https://github.com/p4lang/ptf
cd ptf
git checkout ${PTF_COMMIT}
sudo python3 setup.py install
cd ..

find /usr/lib /usr/local $HOME/.local | sort > $HOME/usr-local-8-after-ptf-install.txt
