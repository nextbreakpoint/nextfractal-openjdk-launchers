#!/bin/bash

if [ -z "$1" ]; then
  echo "Missing argument version"
  exit 1
fi

VERSION=$1

sh -c "cd debian/build && zip -9 debian-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd fedora/build && zip -9 fedora-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd mac/build && zip -9 osx-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd windows/build && zip -9 windows-nextfractal-launcher-$VERSION.zip NextFractal.exe"
