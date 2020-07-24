# Windows Installer

The Windows Installer is built with NSIS.

First, build the container located in `.github/actions/build-nsis`.
Then, just execute `./make`.

If you want to sign the installer and uninstaller, use `SIGN=yes ./make` instead.
You will need a Windows VM with your signing token and access to the build directory.
