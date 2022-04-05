#!/bin/bash

{{ file.Read "templates/snippets/common.sh"}}

if [ -d /var/lib/portmaster/updates ]; then
    log "info" "Detected previous installation of Portmaster at"
    log "info" "/var/lib/portmaster"
    log "info" "Please uninstall the portmaster package and try again!"
    log "info" "You settings will be migrated automatically during re-installation."
    exit 1
fi