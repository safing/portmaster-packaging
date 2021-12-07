#!/bin/bash

{{ file.Read "templates/snippets/common.sh"}}

if [ -d /var/lib/portmaster/updates ]; then
    log "Detected previous installation of Portmaster at"
    log "/var/lib/portmaster"
    log "Please uninstall the portmaster package and try again!"
    log "You settings will be migrated automatically during re-installation."
    exit 1
fi