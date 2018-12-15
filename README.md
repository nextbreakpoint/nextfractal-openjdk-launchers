# nextfractal-openjdk-launchers

Since there are many flavours of Java nowadays, NextFractal started providing an embedded Java JDK and native launchers to ensure that users always have the correct Java runtime and libraries. This project provides the native launchers required for executing NextFractal on Mac, Linux, and Window.


## How to create new launchers

Below you can find the steps required for producing the launchers for Mac, Windows, Linux/Fedora and Linux/Debian.


### Build launcher for Mac

Verify you have installed Xcode (xcodebuild -version). We currently use Xcode 10.1 (Build version 10B61).

Run the build script from mac directory:

    sh build.sh

The script will download the [pre-built JDK and static JLI lib](https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases) for OS X and il will compile the native launcher into directory build.


### Build launcher for Windows

Run the build script from window directory:

    sh build.sh

The script will download the [pre-built JDK](https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases) for Window and it will compile the native launcher into directory build.


### Build launcher for Fedora

Run the build script from fedora directory:

    sh build.sh

The script will download the [pre-built JDK](https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases) for Fedora and it will compile the native launcher into directory build.


### Build launcher for Debian

Run the build script from debian directory:

    sh build.sh

The script will download the [pre-built JDK](https://github.com/nextbreakpoint/nextfractal-openjdk-binaries/releases) for Debian and it will compile the native launcher into directory build.
