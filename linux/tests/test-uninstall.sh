#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. ${SCRIPT_DIR}/common.sh

group "Ensure portmaster is not running"
    if is_systemd_running; then
        if systemctl is-active portmaster.service ; then
            error "portmaster.service should have been stopped on uninstall"
        fi
    else
        debug "Skipping systemd service check ..."
    fi
endgroup

#
# A normal uninstallation should keep user data
# and logs in-place
#
#   group "Settings and logs are kept"
#   if ! [ -d /opt/safing/portmaster/databases ] ; then
#       error "Portmaster databases should have been left in tree"
#   else
#       debug "Portmaster databases are left in tree as expected"
#   fi
#   
#   if ! [ -e /opt/safing/portmaster/config.json ]; then
#       error "Portmaster global settings should have been left in tree"
#   else
#       debug "Portmaster global settings are left in tree as expected"
#   fi
#   
#   if ! [ -d /opt/safing/portmaster/logs ] ; then
#       error "Portmaster logs should have been left in tree"
#   else
#       debug "Portmaster logs are left in tree as expected"
#   fi
#   endgroup

group "Binaries are deleted"
if [ -d /opt/safing/portmaster/updates ]; then
    error "Updates directory should have been removed"
else 
    debug "Updates directory has been removed as expected"
fi
endgroup

finish_tests