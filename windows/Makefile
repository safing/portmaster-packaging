# Note: Built for execution in container .github/actions/build-nsis

STARTURL ?= https://updates.safing.io/latest/windows_amd64/start/portmaster-start.exe
MAKENSIS ?= makensis
WINEPREFIX ?= 

all: portmaster-uninstaller.exe portmaster-installer.exe

prepare-wine:
	 wget -O /tmp/nsis-installer.exe https://downloads.sourceforge.net/project/nsis/NSIS%203/3.08/nsis-3.08-setup.exe\?ts\=gAAAAABhgOi_QwQAJSZpPpH77UeO42NdRuMrbb9gHArOw_q1xuPE-qVke0568R-KvtJXhFvZ6Z142oyJlQYiDDLQtylZsOvtAw%3D%3D\&r\=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fnsis%2Ffiles%2FNSIS%25203%2F3.08%2Fnsis-3.08-setup.exe%2Fdownload%3Fuse_mirror%3Dnav%26download%3D
	 WINEPREFIX=$(shell pwd)/.wine wine /tmp/nsis-installer.exe
	 @echo "run: 'export WINEPREFIX=$(shell pwd)/.wine'"

wine-setup:
ifeq (,$(findstring $(shell pwd),$(WINEPREFIX)))
	which sudo && sudo chown -R $$(id -u):$$(id -g) $(WINEPREFIX) || true
endif

portmaster-start.exe:
	curl --fail --user-agent GitHub -o portmaster-start.exe $(STARTURL)

portmaster-uninstaller.exe: wine-setup portmaster-installer.nsi install_summary.nsh install_finish.nsh
	$(MAKENSIS) -DUNINSTALLER portmaster-installer.nsi
	wine ./uninstaller_pkg.exe
ifdef SIGN
	@echo -e "If wanted, sign now (on Windows) using:\nsign.bat portmaster-uninstaller.exe\npress enter to continue"
	@read x
endif

install_summary.nsh: install_summary.rtf
	echo -n '$${NSD_SetText} $$0 "' > install_summary.nsh
	perl -p -e 's/\r?\n/\$$\\r\$$\\n/' install_summary.rtf >> install_summary.nsh
	echo '"' >> install_summary.nsh

install_finish.nsh: install_finish.rtf
	echo -n '$${NSD_SetText} $$0 "' > install_finish.nsh
	perl -p -e 's/\r?\n/\$$\\r\$$\\n/' install_finish.rtf >> install_finish.nsh
	echo '"' >> install_finish.nsh

portmaster-installer.exe: wine-setup portmaster-start.exe portmaster-installer.nsi portmaster-uninstaller.exe install_summary.nsh install_finish.nsh
	$(MAKENSIS) -DINSTALLER -DPRODUCTION portmaster-installer.nsi #Production enables good compression (takes longer)
ifdef SIGN
	@echo -e "If wanted, sign now (on Windows) using:\nsign.bat portmaster-installer.exe\npress enter to continue"
	@read x
endif

test: portmaster-installer.exe
	mkdir -p /tmp/test-wine
	rm -rf /tmp/test-wine/prefix || true
	WINEPREFIX=/tmp/test-wine/prefix wine ./portmaster-installer.exe

clean:
	rm -f portmaster-uninstaller.exe
	rm -f uninstaller_pkg.exe
	rm -f portmaster-installer.exe
	rm -f install_summary.nsh
	rm -f install_finish.nsh
	rm -rf portmaster-start.exe
