#!/bin/bash
TEMP=$(getopt -u -o uhd:t: -l no-color,no-download,purge,uninstall,no-upgrade,debug,help,assets-url:,start-url:,arch:,tmp-dir: -n 'portmaster-installer' -- "$@")
eval set -- "$TEMP"

if [[ $? -ne 0 ]]; then
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

arch=""
start_url=""
asset_url=""
tmp_dir=""
remove_tmp="no"
upgrade="no"
action="install"
skip_downloads="False"
colorize="yes"

print_help() {
    cat <<EOH
Portmaster Installer

This script will install the Portmaster Application Firewall into
/opt/safing/portmaster.

Options:

  -h, --help                    Display this help text.
  -t TMP, --tmp-dir TMP         The temporary directory to download assets to
  -u, --uninstall               Remove a portmaster installation
  --purge                       Link --uninstall but also purges configuration and logs
  --no-upgrade                  Force installation rather than upgrade routine
  --debug                       Enable debugging
                                This defaults to /
  --start-url URL               The URL to use when downloading portmaster-start. Defaults to the latest version of the local architecture.
  --assets-url URL              The URl to use when downloading the installer assets. Defauls to the lastes version.
  --arch ARCH                   Overwrite the architecture to use. 
  --no-download                 Disable downloading modules. Note that the Portmaster will need
                                to download the modules during first start and will not immediately
                                work.
  --no-color                    Disabled colorized output
                    
EOH
}

log() {
    local color=""
    if [[ ${colorize} == "yes" ]]; then
        case "$1" in
            info )
                color="\u001b[37m- "
                ;;
            warn )
                color="\u001b[11m! "
                ;;
            debug )
                color="\u001b[36m  "
                ;;
            success )
                color="\u001b[32m* "
                ;;
            error )
                color="\u001b[31mx "
                ;;
            * )
                # just in case someone called "log" without a level
                # we need to make sure we dont' lose the message during "shift"
                # below
                color="$1 "
                ;;
        esac
    else
        color="$1: "
    fi

    shift

    echo -e "${color}$*\u001b[0m"
}

header() {
    local color=""
    if [[ ${colorize} == "yes" ]]; then
        color="\u001b[32m"
    fi

    echo -e "${color}Portmaster Installer\u001b[0m"
    echo -e ""
    echo -e "${color} Application Firewall: Block Mass Surveillance - Love Freedom
The Portmaster enables you to protect your data on your device. You
are back in charge of your outgoing connections: you choose what data
you share and what data stays private. Read more on docs.safing.io.\u001b[0m"

    echo -e ""
}

check_bin() {
    command -V "$1" >/dev/null 2>&1
    result=$?

    if [[ $result -ne 0 ]]; then
        log error "$1 is not available locally. Please install it first. (command -V returned $result)"
        exit 1
    fi
}

check_deps() {
    log info "Checking dependencies ..."
    for cmd in curl tar ; do
        check_bin ${cmd}
    done
}

check_arch() {
    if [[ ${arch} == "" ]]; then
        case $(uname -m) in
            x86_64 )
                arch="amd64"
                ;;
            arm64 )
                arch="arm64"
                ;;
            * )
                echo "Unsupported installer architecture $(uname -m). Try running with --arch to overwrite these checks."
                exit 1
        esac

        log info "Detected supported architecture ${arch}"
    fi
}

download_file() {
    curl -fsS --compressed "$1" -o "$2"
}

download_assets() {
    local assets=$1

    if [[ ${asset_url} == "" ]]; then
        asset_url="https://updates.safing.io/latest/linux_all/packages/installer-assets.tar.gz"
    fi

    log info "  Downloading assets from ${asset_url}"
    download_file "${asset_url}" "${assets}"
    log success "  Installer assets downloaded to ${assets}"
}

download_pmstart() {
    local pmstart=$1

    if [[ ${start_url} == "" ]]; then
        start_url="https://updates.safing.io/latest/linux_${arch}/start/portmaster-start"
    fi

    log info "  Downloading portmaster-start from ${start_url}"
    download_file "${start_url}" "${pmstart}"
    log success "  portmaster-start downloaded to ${pmstart}"
}

copy_icons() {
    local failure=0
    for res in /opt/safing/portmaster/icons/* ; do
        cp "$res"/* "/usr/share/icons/hicolor/$(basename "$res")" >/dev/null 2>&1 || failure=1

        if [[ $failure -ne 0 ]]; then
            break
        fi
        echo "/usr/share/icons/hicolor/$(basename "$res")" >> /opt/safing/portmaster/.installed-files
    done

    if [[ $failure -ne 0 ]]; then
        log error "Failed to install portmaster icons to /usr/share/icons/hicolor"
        log debug "If you experience issues with Portmaster application icons try to copy them there manually."
        log debug "You can always find the current portmaster icons at /opt/safing/portmaster/icons"
    else
        log info "  Installed application icons to /usr/share/icons/hicolor"
    fi
}

install_or_upgrade() {
    header

    check_deps

    check_arch

    # form here on, any non-catched error is fatal
    set -e

    if [[ ${tmp_dir} == "" ]]; then
        tmp_dir=$(mktemp -d -t portmaster-installer-XXXXXXXXXX)
        remove_tmp="yes"
    fi

    log info "Downloading portmaster-start and installer assets"

    assets="${tmp_dir}/assets.tar.gz"
    pmstart="${tmp_dir}/portmaster-start"

    download_assets "$assets"
    download_pmstart "$pmstart"

    if [[ "${upgrade}" != "yes" ]]; then
        log info "Creating /opt/safing/portmaster"
        mkdir -p /opt/safing/portmaster
    fi

    # Switch to our new install root
    cd /opt/safing/portmaster

    # Untar the archive on root
    log info "Extracting assets to /opt/safing/portmaster"
    tar --extract --no-same-owner --no-overwrite-dir -m --file="${assets}"
    log info "Fixing asset permissions"
    chmod -R a+r /opt/safing/portmaster

    cp "${pmstart}" /opt/safing/portmaster/portmaster-start
    chmod 0755 /opt/safing/portmaster/portmaster-start

    log success "Extracted assets to /opt/safing/portmaster"

    log info "Copying system files"
    copy_icons

    # Source installer script
    source /opt/safing/portmaster/.INSTALL.sh

    if [[ "${upgrade}" == "yes" ]]; then
        log info "Running post-upgrade scripts ..."
        post_upgrade
    else
        log info "Running post-install scripts ..."
        log debug "This will download all required portmaster modules and files." 
        log debug "Depending on your internet connection speed this may take a few minutes" 
        log debug "to complete."

        log debug "If you don't want to download modules abort the installer and re-run with"
        log debug "--no-download --no-upgrade"

        # skip_downloads is used in post_install which is sourced from .INSTALL.sh
        # so we need to export it here.
        export skip_downloads
        post_install
    fi

    log info "Cleaning up temporary directory"
    # Remove the temporary directory
    if [[ "$remove_tmp" != "no" ]]; then
        rm -rf "${tmp_dir}"
    fi

    log success "Portmaster is now installed."
    log success "Please restart your device to start Portmaster"
    exit 0
}

remove() {
    if ! test -f /opt/safing/portmaster/.installed-files ; then
        log error "Portmaster has not been installed with this install script."
        log error "Please try to use the uninstallation method of your package manager"
        exit 1
    fi

    log info "Removing portmaster installation"

    # Switch to our install root
    cd /opt/safing/portmaster

    # Source installer script
    source /opt/safing/portmaster/.INSTALL.sh

    log info "Running pre-remove scripts ..."
    pre_remove "$1"

    # for the next steps we need to switch to the system root
    xargs rm -v 2>/dev/null >&2 <.installed-files
    log success "Installed files deleted"

    log info "Running post-remove scripts ..."
    post_remove "$1"

    exit 0
}

# detect if this is an upgrade or not
if test -d /opt/safing/portmaster ; then
    upgrade="yes"
fi

while true; do 
    case "$1" in
        --debug)
            set -x
            shift
            ;;
        --assets-url)
            asset_url="$2"
            shift 2
            ;;
        --start-url)
            start_url="$2"
            shift 2
            ;;
        --arch)
            arch="$2"
            shift 2
            ;;
        -t|--tmp-dir)
            tmp_dir="$2"
            remove_tmp="no"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        --no-upgrade)
            upgrade="no"
            shift
            ;;
        -u|--uninstall)
            action="uninstall"
            shift
            ;;
        --purge)
            action="purge"
            shift
            ;;
        --no-download)
            skip_downloads="True"
            shift
            ;;
        --no-color)
            colorize="no"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

case "$action" in
    install )
        install_or_upgrade
        ;;
    uninstall | purge )
        remove "$action"
        ;;
esac