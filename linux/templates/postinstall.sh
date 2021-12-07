#!/bin/bash

{{ file.Read "templates/snippets/common.sh"}}

download_agent="${PMSTART_UPDATE_AGENT:=Start}"
skip_downloads="${PMSTART_SKIP_DOWNLOAD:=False}"

{{ file.Read "templates/snippets/install-systemd-utils.sh" }}

cleanInstall() {
{{ file.Read "templates/snippets/post-install.sh" | strings.Indent 4 " " }}
}

upgrade() {
{{ file.Read "templates/snippets/post-upgrade.sh" | strings.Indent 4 " " }}

  cleanInstall
}

# Step 2, check if this is a clean install or an upgrade
action="$1"
if  [ "$1" = "configure" ] && [ -z "$2" ]; then
  # Alpine linux does not pass args, and deb passes $1=configure
  action="install"
elif [ "$1" = "configure" ] && [ -n "$2" ]; then
    # deb passes $1=configure $2=<current version>
    action="upgrade"
fi

case "$action" in
  "1" | "install")
    cleanInstall
    ;;
  "2" | "upgrade")
    upgrade
    ;;
  *)
    # Alpine
    # $1 == version being installed  
    cleanInstall
    ;;
esac
