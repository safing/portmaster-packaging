#!/bin/sh
set -e

cd windows

make

mv *.exe ../
filename='portmaster-installer.exe'
echo ::set-output name=filename::$filename