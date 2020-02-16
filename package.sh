#!/bin/bash

VERSION=1.1

sh -c "cd osx/build && zip -9 osx-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd debian/build && zip -9 debian-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd fedora/build && zip -9 fedora-nextfractal-launcher-$VERSION.zip NextFractal"
sh -c "cd windows/build && zip -9 windows-nextfractal-launcher-$VERSION.zip NextFractal.exe"

mkdir -p dist

cp osx/build/osx-nextfractal-launcher-$VERSION.zip dist
cp debian/build/debian-nextfractal-launcher-$VERSION.zip dist
cp fedora/build/fedora-nextfractal-launcher-$VERSION.zip dist
cp windows/build/windows-nextfractal-launcher-$VERSION.zip dist
