#!/usr/bin/env bash
# shellcheck disable=SC1090
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

write_iwd_config() {
    log "write iwd config"
    sudo mkdir -p /etc/iwd
    sudo tee /etc/iwd/main.conf > /dev/null <<EOF
[General]
use_default_interface=true
EOF
}

write_networkd_config() {
    local interface="${1}"

    log "write networkd config"

    sudo tee /etc/systemd/network/10-eth.network > /dev/null <<EOF
[Match]
Name=${interface}

[Network]
DHCP=yes
EOF

    sudo tee /etc/systemd/network/20-bridge.netdev > /dev/null <<EOF
[NetDev]
Name=br0
Kind=bridge
EOF

    sudo tee /etc/systemd/network/20-bridge.network > /dev/null <<EOF
[Match]
Name=${interface}

[Network]
Bridge=br0
EOF
}

start_networkd() {
    log "start networkd"
    sudo systemctl start systemd-networkd
    sudo systemctl enable systemd-networkd > /dev/null
}

stop_nm() {
    log "stop NetworkManager"
    sudo systemctl stop NetworkManager
}

remove_nm() {
    log "remove NetworkManager"
    sudo systemctl disable NetworkManager > /dev/null
    sudo dnf remove -y NetworkManager > /dev/null
}

main() {
    if [[ "$#" -ne 1 ]]; then
        error "Usage: ${0} <interface>"
    fi
    local interface="${1}"

    update_dnf
    install iwd

    write_iwd_config
    write_networkd_config "${interface}"

    stop_nm
    start_networkd
    remove_nm
}

main "$@"
