#!/usr/bin/make -f
STARTURL ?= https://updates.safing.io/latest/linux_amd64/start/portmaster-start\?CI
NFPM ?= nfpm

.PHONY: icons test-debian test-ubuntu  nfpm.yaml

all: deb rpm gen-pkgbuild gen-archive

nfpm.yaml: portmaster-start
	sed -e "s/^version:.*$$/version: v$(shell ./portmaster-start version --short)-$(shell cat ./pkgrev)/g" ./nfpm.yaml.template > ./nfpm.yaml

build: icons nfpm.yaml gen-scripts gen-pkgbuild

icons:
	for res in 16 32 48 96 128 ; do \
		mkdir -p icons/$${res}x$${res} ; \
		convert ./portmaster_logo.png -resize "$${res}x$${res}" "icons/$${res}x$${res}/portmaster.png" ; \
	done

portmaster-start:
	curl --fail --user-agent GitHub -o portmaster-start $(STARTURL)
	chmod +x ./portmaster-start

deb: distdir build
	$(NFPM) package --packager deb -t dist

rpm: distdir build
	$(NFPM) package --packager rpm -t dist

distdir:
	mkdir -p ./dist

clean:
	rm -r ./portmaster-start ./scripts ./dist icons/ PKGBUILD arch.install nfpm.yaml src pkg  portmaster-bin-*.pkg.tar.xz archive.install || true

test-debian: build deb
	docker run -ti --rm -v $(shell pwd)/dist:/work -w /work debian:latest bash -c 'apt update && apt install -y ca-certificates && dpkg -i /work/portmaster*.deb ; bash'

test-ubuntu: build deb
	docker run -ti --rm -v $(shell pwd)/dist:/work -w /work ubuntu:latest bash -c 'apt update && apt install -y ca-certificates && dpkg -i /work/portmaster*.deb ; bash'

increase-pkgrev:
	bash -c 'rev=$$(cat pkgrev) ; ((rev++)) ; echo $${rev} > ./pkgrev'

reset-pkgrev:
	echo 1 > ./pkgrev

gen-scripts: 
	mkdir -p ./scripts
	for file in "rules" "preinstall.sh" "postinstall.sh" "preremove.sh" "postremove.sh"; do \
		gomplate -f "templates/$${file}" > "./scripts/$${file}" ; \
	done;

gen-pkgbuild: nfpm.yaml
	gomplate -d "nfpm=./nfpm.yaml" -f templates/arch.install > arch.install
	gomplate -d "nfpm=./nfpm.yaml" -f templates/PKGBUILD > PKGBUILD

gen-archive: nfpm.yaml icons
	gomplate -d "nfpm=./nfpm.yaml" -f templates/no-log-install.sh > archive.install
	gomplate -d "nfpm=./nfpm.yaml" -f templates/create-archive.sh | bash

lint:
	shellcheck ./scripts/* ./arch.install 