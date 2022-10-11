#
# install .desktop files, either using desktop-file-install when available
# or by just copying the files into /usr/share/applications.
#
if command -V desktop-file-install >/dev/null 2>&1; then
    desktop-file-install /opt/safing/portmaster/portmaster.desktop 2>/dev/null ||:
    desktop-file-install /opt/safing/portmaster/portmaster_notifier.desktop 2>/dev/null ||
        log error "Failed to install .desktop files. Please copy /opt/safing/portmaster/*.desktop manually"
elif [ -d /usr/share/applications ]; then
    cp /opt/safing/portmaster/portmaster.desktop /opt/safing/portmaster/portmaster_notifier.desktop /usr/share/applications 2>/dev/null ||
        log error "Failed to install .desktop files. Please copy /opt/safing/portmaster/*.desktop manually"
fi

installSystemdSupport

#
# Fix selinux permissions for portmaster-start if we have semanage
# available.
#
if command -V semanage >/dev/null 2>&1; then
    semanage fcontext -a -t bin_t -s system_u $(realpath /opt)'/safing/portmaster/portmaster-start' || :
    semanage fcontext -a -t bin_t -s system_u $(realpath /opt)'/safing/portmaster/updates/linux_(.*)' || :
    restorecon -R /opt/safing/portmaster 2>/dev/null >&2 || :
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
    log "info" "Downloading of Portmaster modules skipped!"
    log "info" "Please run '/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update' manually.\n"
    return
fi
log "Downloading portmaster modules. This may take a while ..."
/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update --update-agent "${download_agent}" 2>/dev/null >/dev/null || (
    log "error" "Failed to download modules"
    log "error" "Please run '/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster update' manually.\n"
)

# finally, once we donwloaded the modules restore the SE-linux context
# for all downloaded files
if command -V semanage >/dev/null 2>&1; then
    restorecon -R /opt/safing/portmaster 2>/dev/null >&2 || :
fi