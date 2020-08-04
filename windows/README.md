# Windows Installer

The Windows Installer is built with NSIS.

Usage:
```sh
cd portmaster-packaging/.github/actions/build-nsis
#Build the Container
sudo docker build -t build-nsis .
cd ../../..
# Run the container to build the Installer
sudo docker run --rm -ti -v $(pwd):/workspace -w /workspace build-nsis

# If you want to sign the executable, add SIGN=yes so the build process stops
# and waits for you to sign the binaries.
sudo docker run --rm -e SIGN=yes -ti -v $(pwd):/workspace -w /workspace build-nsis
```

If you want to sign the installer and uninstaller, use `SIGN=yes ./make` instead.
You will need a Windows VM with your signing token and access to the build directory.
