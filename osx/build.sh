#/bin/sh

export VERSION=11.0.2-0

export BUILD_DIR=$(pwd)/build

export JDK_ROOT=$(pwd)/nextfractal-jdk-${VERSION}

export SDK_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk

if [ ! -f "osx-nextfractal-jdk-${VERSION}.zip" ]; then
  wget -O osx-nextfractal-jdk-${VERSION}.zip https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v${VERSION}/osx-nextfractal-jdk-${VERSION}.zip
fi

if [ ! -d "osx-nextfractal-jdk-${VERSION}" ]; then
  unzip osx-nextfractal-jdk-${VERSION}.zip
fi

if [ ! -f "osx-libjli-static-${VERSION}.zip" ]; then
  wget -O osx-libjli-static-${VERSION}.zip https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v${VERSION}/osx-libjli-static-${VERSION}.zip
fi

if [ ! -d "osx-libjli-static-${VERSION}" ]; then
  unzip osx-libjli-static-${VERSION}.zip
fi

mkdir -p $BUILD_DIR

make
