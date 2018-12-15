#/bin/sh

export BUILD_DIR=$(pwd)/build

export JDK_ROOT=$(pwd)/jdk-11.0.1

if [ ! -f "jdk-11.0.1-0.tar.bz2" ]; then
  wget -O jdk-11.0.1-0.tar.bz2 https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v11.0.1-0/windows-jdk-11.0.1-0.zip
fi

if [ ! -d "jdk-11.0.1" ]; then
  unzip jdk-11.0.1-0.tar.bz2
fi

mkdir -p $BUILD_DIR

make
