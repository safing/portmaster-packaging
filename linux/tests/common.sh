#!/bin/bash

#
# Utility methods for writing debug, warning and error messages
# for github-actions.
#
error_count=0
debug() {
    printf "::debug::%s\n" "$@"
}
info() {
    printf "::notice::%s\n" "$@"
}
error() {
    ((error_count++))
    printf "::error::%s\n" "$@"
}
warn() {
    printf "::warning::%s\n" "$@"
}
group() {
    printf "::group::%s\n" "$1"
}
endgroup() {
    printf "::endgroup::\n"
}

#
# Source /etc/os-release and gather some facts
# for os/distribution specific tests
#
. /etc/os-release

systemd_running=""

# is_systemd_running lazily detects if systemd is running in the current
# environment.
is_systemd_running() {
    if [ "${systemd_running}" = "" ]; then
        systemd_running="False"
        if [ "$(pgrep systemd | head -n1)" = "1" ]; then
            debug "Found systemd running at $(pgrep systemd | head -1)"
            systemd_running="True"
        fi
    fi

    if [ "${systemd_running}" = "True" ]; then
        return 0
    fi

    return 1
}

finish_tests() {
    #
    # Abort with a non-zero exit code if we found at least one
    # error.
    #
    if [ "$error_count" -gt 0 ]; then
        echo "::error::${error_count} errors encountered"
        exit 1
    fi
}