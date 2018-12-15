#/bin/sh

export BUILD_DIR=$(pwd)/build

export JDK_ROOT=$(pwd)/jdk-11.0.1

export SDK_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk

if [ ! -f "jdk-11.0.1-0.tar.bz2" ]; then
  wget -O jdk-11.0.1-0.tar.bz2 https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v11.0.1-0/osx-jdk-11.0.1-0.tar.bz2
fi

if [ ! -d "jdk-11.0.1" ]; then
  tar -xf jdk-11.0.1-0.tar.bz2
fi

if [ ! -f "libjli_static-11.0.1-0.tar.bz2" ]; then
  wget -O libjli_static-11.0.1-0.tar.bz2 https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v11.0.1-0/osx_libjli_static-11.0.1-0.tar.bz2
fi

if [ ! -f "libjli_static.a" ]; then
  tar -xf libjli_static-11.0.1-0.tar.bz2
fi

mkdir -p $BUILD_DIR

make
