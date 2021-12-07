#
# install .desktop files, either using desktop-file-install when available
# or by just copying the files into /usr/share/applications.
#
if command -V desktop-file-install >/dev/null 2>&1; then
    desktop-file-install /opt/safing/portmaster/portmaster.desktop ||:
    desktop-file-install /opt/safing/portmaster/portmaster_notifier.desktop ||:
elif [ -d /usr/share/applications ]; then
    cp /opt/safing/portmaster/portmaster.desktop /usr/share/applications 2>/dev/null ||:
    cp /opt/safing/portmaster/portmaster_notifier.desktop /usr/share/applications 2>/dev/null ||:
fi

installSystemdSupport

#
# Fix selinux permissions for portmaster-start
#
if command -V getenforce >/dev/null 2>&1; then
    chcon -t bin_t /opt/safing/portmaster/portmaster-start
fi

#
# Prepare the installation directory tree
#
/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster clean-structure

#
# Finally, trigger downloading modules. As this requires internet access
# it is more likely to fail and is thus the last thing we do.
#
if [ "${skip_downloads}" = "True" ]; then
    log "Downloading of Portmaster modules skipped!"
    log "Please run '/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update' manually.\n"
    return
fi
log "Downloading portmaster modules. This may take a while ..."
/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update --update-agent "${download_agent}" 2>/dev/null >/dev/null || (
    log "Failed to download modules"
    log "Please run '/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update' manually.\n"
)