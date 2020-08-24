# Note: Built for execution in container .github/actions/build-nsis

STARTURL ?= https://updates.safing.io/latest/windows_amd64/start/portmaster-start.exe\?client=Github

all: portmaster-uninstaller.exe portmaster-installer.exe

portmaster-start.exe:
	curl --fail --user-agent GitHub -o portmaster-start.exe $(STARTURL)

portmaster-uninstaller.exe: portmaster-installer.nsi install_summary.nsh
	echo hi
	makensis -DUNINSTALLER portmaster-installer.nsi
	WINEPREFIX=/tmp wine ./uninstaller_pkg.exe
ifdef SIGN
	@echo -e "If wanted, sign now (on Windows) using:\nsign.bat portmaster-uninstaller.exe\npress enter to continue"
	@read x
endif

install_summary.nsh: install_summary.rtf
	echo -n '$${NSD_SetText} $$0 "' > install_summary.nsh
	perl -p -e 's/\r?\n/\$$\\r\$$\\n/' install_summary.rtf >> install_summary.nsh
	echo '"' >> install_summary.nsh

portmaster-installer.exe: portmaster-start.exe portmaster-installer.nsi portmaster-uninstaller.exe install_summary.nsh
	makensis -DINSTALLER -DPRODUCTION portmaster-installer.nsi #Production enables good compression (takes longer)
ifdef SIGN
	@echo -e "If wanted, sign now (on Windows) using:\nsign.bat portmaster-installer.exe\npress enter to continue"
	@read x
endif

clean:
	rm -f portmaster-uninstaller.exe
	rm -f uninstaller_pkg.exe
	rm -f portmaster-installer.exe
	rm -f install_summary.nsh
	rm -rf portmaster-start.exe
