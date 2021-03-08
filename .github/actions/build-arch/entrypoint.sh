#!/bin/bash

set -e

cd linux
id docker || (echo creating user docker; useradd docker)
chown -R docker:docker .

# Reset PKGEXT to it's default (it's different in the build-container)
PKGEXT=".pkg.tar.xz" su docker -c makepkg

ls -lah

pkgname=$(ls *.pkg.tar*)
mv $pkgname ../$pkgname
echo ::set-output name=filename::$pkgname