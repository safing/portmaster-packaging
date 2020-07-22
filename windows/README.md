# Windows Installer

The Windows Installer is built with NSIS.

Here is how:
1. [Linux] download latest portmaster-start: `make portmaster-start.exe`
2. [Linux] build uninstaller: `make portmaster-uninstaller.exe`
3. [Windows] sign uninstaller: `sign.bat portmaster-uninstaller.exe`
4. [Linux] build installer (includes the uninstaller): `make portmaster-installer.exe`
5. [Windows] sign installer: `sign.bat portmaster-uninstaller.exe`
6. copy to dist directory with versioned file name
