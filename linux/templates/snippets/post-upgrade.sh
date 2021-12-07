#
# As of 0.4.0 portmaster-control has been renamed to portmaster-start
# and is not placed in /usr/bin anymore. Unfortunately, the postrm script
# of the old installer does not get rid of portmaster-control so we should
# take care during an upgrade.
#
rm /usr/bin/portmaster-control 2>/dev/null >&2 ||:

#
# If there's already a /var/lib/portmaster installation we're going to move
# configs and databases and remove the complete directory
# The preinstall.sh already checked that /var/lib/portmaster/updates MUST NOT
# exist so we should be safe to touch the databases here.
#
if [ -d /var/lib/portmaster ]; then
    if [ ! -d /opt/safing/portmaster/config.json ]; then
        log "Migrating from previous installation at /var/lib/portmaster to /opt/safing/portmaster ..."
        mv /var/lib/portmaster/databases /opt/safing/portmaster/databases ||:
        mv /var/lib/portmaster/config.json /opt/safing/portmaster/config.json ||:
    fi
    log "Removing previous installation directory at /var/lib/portmaster"
    rm -r /var/lib/portmaster 2>/dev/null >&2 ||:
fi
