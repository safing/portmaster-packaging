#!/bin/bash

set -e

cd linux

# Reset PKGEXT to it's default (it's different in the build-container)
PKGEXT=".pkg.tar.xz" makepkg

ls -lah

pkgname=$(ls *.pkg.tar*)
mv $pkgname ../$pkgname
echo ::set-output name=filename::$pkgname