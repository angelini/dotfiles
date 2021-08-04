#!/usr/bin/env bash
# shellcheck disable=SC1091
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

add_dnf_repo() {
    local name="${1}"
    local uri="${2}"

    log "install DNF repo ${name}"

    install dnf-plugins-core
    if ! dnf repolist enabled | grep "${name}" > /dev/null; then
        sudo dnf config-manager --add-repo "${uri}" > /dev/null
    fi
}
