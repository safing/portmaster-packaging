#!/bin/bash

{{ file.Read "templates/snippets/common.sh"}}

uninstall() {
{{ file.Read "templates/snippets/post-remove.sh" | strings.Indent 4 " " }}
}

action="$1"
if  [ "$1" = "remove" ] && [ -z "$2" ]; then
    # Alpine linux does not pass args
    # deb passes $1=remove
    # rpm passes $1=0
    action="uninstall"
elif [ "$1" = "purge" ] && [ -z "$2" ]; then
    # deb passes $1=purge, Alpine and RPM does not have purge at all
    action="purge"
elif [ "$1" = "upgrade" ] && [ -n "$2" ]; then
    # deb passes $1=upgrade $2=version
    # rpm passes $1=1
    action="upgrade"
fi

case "$action" in
    "0" | "uninstall" | "purge")
      log "post remove of complete uninstall"
      uninstall "$action"
      ;;
    "1" | "upgrade")
      log "post remove of upgrade"
      ;;
    *)
      # $1 == version being installed  
      log "post remove of alpine"
      log "Alpine linux is not yet supported"
      exit 1
      ;;
esac

