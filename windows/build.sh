#/bin/sh

export VERSION=11.0.2-0

export BUILD_DIR=$(pwd)/build

export JDK_ROOT=$(pwd)/nextfractal-jdk-${VERSION}

if [ ! -f "windows-nextfractal-jdk-${VERSION}.zip" ]; then
  wget -O windows-nextfractal-jdk-${VERSION}.zip https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v${VERSION}/windows-nextfractal-jdk-${VERSION}.zip
fi

if [ ! -d "windows-nextfractal-jdk-${VERSION}" ]; then
  unzip windows-nextfractal-jdk-${VERSION}.zip
fi

mkdir -p $BUILD_DIR

make
