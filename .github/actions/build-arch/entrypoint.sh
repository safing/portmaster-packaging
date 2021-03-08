#!/bin/bash

set -e
cd linux

# Create user "docker" because makepkg refuses to run as root.
id docker || (echo creating user docker; useradd docker)
chown -R docker:docker .

# Set PKGDEST to a location where user "docker" can write.
export PKGDEST="/tmp/pkg"
mkdir -p $PKGDEST
chown -R docker:docker $PKGDEST
# Reset PKGEXT to it's default (it's different in the build-container).
export PKGEXT=".pkg.tar.xz"

# Build package.
su docker -c makepkg

# Check result and prepare for uploading.
ls -lah
pkgname=$(ls *.pkg.tar*)
mv $pkgname ../$pkgname
echo ::set-output name=filename::$pkgname
