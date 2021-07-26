#!/usr/bin/env bash
# shellcheck disable=SC1091
# shellcheck disable=SC2155

set -euo pipefail

source "${BASH_SOURCE%/*}/common.sh"

write_iwd_config() {
    local ssid="${1}"
    local passphrase="${2}"

    log "write iwd config"

    sudo mkdir -p /etc/iwd
    sudo tee /etc/iwd/main.conf > /dev/null <<EOF
[General]
EOF

    sudo mkdir -p /var/lib/iwd/
    sudo tee "/var/lib/iwd/${ssid}.psk" > /dev/null <<EOF
[Security]
Passphrase=${passphrase}
EOF
}

write_networkd_wired_config() {
    local interface="${1}"

    log "write networkd wired config"

    sudo tee /etc/systemd/network/10-eth.network > /dev/null <<EOF
[Match]
Name=${interface}

[Network]
Address=10.1.1.3/24
Gateway=10.1.1.0
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

write_networkd_wireless_config() {
    local interface="${1}"

    log "write networkd wireless config"

    sudo tee /etc/systemd/network/30-wireless.network > /dev/null <<EOF
[Match]
Name=${interface}

[Network]
DHCP=yes
EOF
}

set_firewall_zone() {
    local zone="${1}"
    log "setting firewalld zone to ${zone}"
    sudo firewall-cmd --set-default-zone "${zone}"
}

restart_iwd() {
    log "restart iwd"
    sudo systemctl restart iwd
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
    if [[ "$#" -ne 4 ]]; then
        error "Usage: ${0} <wired_interface> <wireless_interface> <ssid> <passphrase>"
    fi
    local wired_interface="${1}"
    local wireless_interface="${2}"
    local ssid="${3}"
    local passphrase="${4}"

    update_dnf
    install iwd

    write_iwd_config "${ssid}" "${passphrase}"
    write_networkd_wired_config "${wired_interface}"
    write_networkd_wireless_config "${wireless_interface}"

    set_firewall_zone "trusted"

    restart_iwd
    stop_nm
    start_networkd
    remove_nm
}

main "$@"
