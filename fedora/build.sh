#/bin/sh

export VERSION=11.0.2-0

export BUILD_DIR=$(pwd)/build

export JDK_ROOT=$(pwd)/nextfractal-jdk-${VERSION}

if [ ! -f "fedora-nextfractal-jdk-${VERSION}.zip" ]; then
  wget -O fedora-nextfractal-jdk-${VERSION}.zip https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases/download/v${VERSION}/fedora-nextfractal-jdk-${VERSION}.zip
fi

if [ ! -d "fedora-nextfractal-jdk-${VERSION}" ]; then
  unzip fedora-nextfractal-jdk-${VERSION}.zip
fi

mkdir -p $BUILD_DIR

make
