#!/bin/bash

GRPC_COMMIT="tags/v1.17.2"

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
