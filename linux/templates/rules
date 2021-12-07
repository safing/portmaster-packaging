#!/usr/bin/make -f
#export DH_VERBOSE = 1

%:
	dh $@

#Don't run strip for go-binaries
override_dh_strip:

override_dh_installsystemd:
	dh_installsystemd -r
