#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. ${SCRIPT_DIR}/common.sh

#
# Perform our tests
#
group "Systemd Integration"
    #
    # the following tests only work if the system is booted using
    # systemd 
    #
    if is_systemd_running ; then
        debug "Test if portmaster.service can be reached"
        if ! systemctl cat portmaster.service 2>/dev/null >&2 ; then
            error "portmaster.service not found"
        else
            debug "portmaster.service found by systemd"
        fi
    else
        debug "Skipping systemctl checks ..."
    fi

    #
    # The following tests should work without the daemon running except
    # on Mint19 ...
    #
    if ! [ "${VERSION}" = "19 (Tara)" ] || is_systemd_running ; then # Skip systemd tests on Mint19 ...
        debug "Use systemd-analyze to verify portmaster.service"
        if ! systemd-analyze verify portmaster.service ; then
            error "systemd-analyze returned an error for portmaster.service"
        else
            debug "systemd-analyze check successful"
        fi
    else
        debug "Skipping systemd-analyze checks ..."
    fi
endgroup

group "Desktop file"
    debug "Testing portmaster.desktop"
    if ! desktop-file-validate /usr/share/applications/portmaster.desktop ; then
        error "portmaster.desktop seems invalid"
    else
        debug "portmaster.desktop seems valid"
    fi

    debug "Testing portmaster_notifier.desktop"
    if ! desktop-file-validate /usr/share/applications/portmaster_notifier.desktop ; then
        error "portmaster_notifier.desktop seems invalid"
    else
        debug "portmaster_notifier.desktop seems valid"
    fi
endgroup

group "Modules"
    if ! [ -e /opt/safing/portmaster/updates/stable.json ]; then
        error "Expected stable.json to have been downloaded"
    else
        debug "stable.json correctly downloaded from update server"
    fi
endgroup


finish_tests