rm -rf /opt/safing/portmaster/updates ||:

# file is marked as a ghost on RPM system so it might have
# been automatically deleted by the package manager.
rm /lib/systemd/system/portmaster.service 2>/dev/null >&2 ||:
rm /usr/share/applications/portmaster.desktop 2>/dev/null >&2 ||:
rm /usr/share/applications/portmaster_notifier.desktop 2>/dev/null >&2 ||:

if [ "$1" = "purge" ]; then
    rm -rf /opt/safing/portmaster ||:
fi
