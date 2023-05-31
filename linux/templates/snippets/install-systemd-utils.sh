#
# Prepares systemd support by creating a symlink for the .service file
# and enabling/disabling certain features of our .service unit based on
# the available systemd version. 
#
installSystemdSupport() {
    local changed="False"
    if command -V systemctl >/dev/null 2>&1; then
        local systemd_version="$(systemctl --version | head -1 | sed -n 's/systemd \([0-9]*\).*/\1/p')"
        # not all distros have migrated /lib to /usr/lib yet but all that
        # have provide a symlink from /lib -> /usr/lib so we just prefix with
        # /lib here.
        ln -s /opt/safing/portmaster/portmaster.service /lib/systemd/system/portmaster.service 2>/dev/null >&2 || 
            log error "Failed to install systemd unit file. Please copy /opt/safing/portmaster/portmaster.service to /etc/systemd/system manually"

        # rhel/centos8 does not yet have ProtectKernelLogs available
        if [ "${systemd_version}" -lt 244 ]; then
            sed -i "s/^ProtectKernelLogs/#ProtectKernelLogs/g" /opt/safing/portmaster/portmaster.service ||:
            changed="True"
        fi

        if [ "${changed}" = "True" ] && [ "$1" = "upgrade" ]; then
            systemctl daemon-reload ||:
        fi

        log "info" "Configuring portmaster.service to launch at boot"
        systemctl enable portmaster.service ||:
    fi
}