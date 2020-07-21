#!/bin/sh
set -e

cd linux

# Set the install command to be used by mk-build-deps (use --yes for non-interactive)
install_tool="apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes"

mk-build-deps --install --tool="${install_tool}" debian/control
dpkg-buildpackage $@

cd ..
ls -lah
filename=`ls *.deb | grep -v -- -dbgsym`
echo ::set-output name=filename::$filename