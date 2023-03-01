# stop the portmaster service and disable it if it's enabled.
if command -V systemctl >/dev/null 2>&1; then
    if (systemctl -q is-active portmaster.service); then
        log "info" "Stopping portmaster.service"
        systemctl stop portmaster.service ||:
    fi
    if (systemctl -q is-enabled portmaster.service); then
        log "info" "Disabling portmaster.service to launch at boot"
        systemctl disable portmaster.service ||:
    fi
fi