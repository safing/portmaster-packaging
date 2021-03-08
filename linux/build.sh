#!/bin/bash

# Check for prerequisites.
if [[ $(which convert) == "" ]]; then
  echo "cannot find command convert, please install imagemagick"
  exit 1
fi
if [[ $(which dpkg-buildpackage) == "" ]]; then
  echo "cannot find command dpkg-buildpackage, please install debhelper"
  exit 1
fi

dpkg-buildpackage --no-sign
