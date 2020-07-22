WINE := $(shell command -v wine 2> /dev/null)

all: portmaster-uninstaller.exe portmaster-installer.exe

portmaster-control.exe:
	curl -o portmaster-control.exe --fail https://updates.safing.io/latest/windows_amd64/control/portmaster-control.exe

portmaster-uninstaller.exe: portmaster-installer.nsi install_summary.nsh
	makensis -DUNINSTALLER portmaster-installer.nsi
ifndef WINE
		sudo docker run --rm -it -v $(shell pwd):/mnt jamesnetherton/wine /mnt/uninstaller_pkg.exe
		sudo chown $(shell id -u)":"$(shell id -g) portmaster-uninstaller.exe uninstaller_pkg.exe
else
		# CI support, we have wine available
		WINEPREFIX=/tmp wine ./uninstaller_pkg.exe
endif
	#TODO: sign

install_summary.nsh:
	echo -n '$${NSD_SetText} $$0 "' > install_summary.nsh
	perl -p -e 's/\r?\n/\$$\\r\$$\\n/' install_summary.rtf >> install_summary.nsh
	echo '"' >> install_summary.nsh

portmaster-installer.exe: portmaster-control.exe portmaster-installer.nsi portmaster-uninstaller.exe install_summary.nsh
	makensis -DINSTALLER -DPRODUCTION portmaster-installer.nsi #Production enables good compression (takes longer)
	#TODO: sign

clean:
	rm -f portmaster-uninstaller.exe
	rm -f uninstaller_pkg.exe
	rm -f portmaster-installer.exe
	rm -f install_summary.nsh
	rm -rf portmaster-control.exe
