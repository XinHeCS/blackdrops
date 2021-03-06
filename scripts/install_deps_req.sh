#!/bin/bash

OS=$(uname)
echo "Detected OS: $OS"

if [ $OS = "Darwin" ]; then
    echo "Installing for OSX via brew"
    brew install cmake eigen3 boost
    brew install autoconf automake
else
    echo "Installing for Ubuntun via apt-get"
    sudo apt-get -qq update
    # install Eigen 3, Boost
    sudo apt-get --yes --force-yes install cmake libeigen3-dev libboost-serialization-dev libboost-filesystem-dev libboost-test-dev libboost-program-options-dev libboost-thread-dev libboost-regex-dev
    # install google tests for libcmaes
    sudo apt-get --yes --force-yes install libgtest-dev autoconf automake libtool libgoogle-glog-dev libgflags-dev
fi

# save current directory
cwd=$(pwd)
# create install dir
mkdir -p install

# do libgtest fix for libcmaes (Linux only)
if [ $OS = "Linux" ]; then
    cd /usr/src/gtest
    sudo mkdir -p build && cd build
    sudo cmake ..
    sudo make
    sudo cp *.a /usr/lib
fi

# install libcmaes
cd ${cwd}/deps/libcmaes
mkdir -p build && cd build
# no tbb for libcmaes
cmake -DUSE_TBB=OFF -DUSE_OPENMP=ON -DBUILD_PYTHON=ON -DCMAKE_INSTALL_PREFIX=${cwd}/install ..
make -j4
make install
# go back to original directory
cd ../../..

# configure paths
source ./scripts/paths.sh

# installing NLOpt
cd deps
wget http://members.loria.fr/JBMouret/mirrors/nlopt-2.4.2.tar.gz
tar -zxvf nlopt-2.4.2.tar.gz && cd nlopt-2.4.2
./configure -with-cxx --enable-shared --without-python --without-matlab --without-octave --prefix=${cwd}/install
make install
# go back to original directory
cd ../..

# just as fail-safe
sudo ldconfig