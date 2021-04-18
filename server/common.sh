#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC2155

set -euo pipefail

log() {
    echo "$(date +"%H:%M:%S") - $(printf '%s' "$@")" 1>&2
}

error() {
    local message="${1}"

    echo "$(date +"%H:%M:%S") - ERROR: $(printf '%s' "${message}")" >&2
    exit 55
}

update_dnf() {
    log "update dnf"
    sudo dnf update -y > /dev/null
}

install() {
    local package="${1}"

    if ! dnf list installed "${package}" &> /dev/null; then
        log "install ${package}"
        sudo dnf install -y "${package}" > /dev/null
    fi
}
